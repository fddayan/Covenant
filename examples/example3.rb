# frozen_string_literal: true

module Ledger
  module Contracts
    CreateTransfer = Covenant.Contract(:CreateTransfer, :any, :any)
    CreateTransaction = Covenant.Contract(:CreateTransaction, :any, :any)
    GetTransactionsByAccount = Covenant.Contract(:GetTransactionsByAccount, :any, :any)

    GetAccountById = Covenant.Contract(:GetAccountById, :any, :any)
    GetTransactionById = Covenant.Contract(:GetTransactionById, :any, :any)
    GetAccountBalance = Covenant.Contract(:GetAccountBalance, :any, :any)
    GetTransferById = Covenant.Contract(:GetTransferById, :any, :any)

    AccountId = Covenant.Scalar(:AccountId, Covenant.Validate.coerce(:integer))
    Amount = Covenant.Scalar(:Amount, Covenant.Validate.coerce(:float))

    CreateTransferPayload = Covenant.Schema(:CreateTransferPayload,
                                            fromAccountId: AccountId,
                                            toAccountId: AccountId,
                                            amount: Amount)

    # CreateTransfer = CreateTransferPayload.def do |payload|
    #   # GetAccountById,
    #   # GetAccountById
    # end

    MoveMoney = Covenant.Do.pipe(
      CreateTransferPayload,
      Covenant.Do.bind(:hasBalance, CheckBalance) { |ctx| { account: ctx[:fromAccount] } },
      Covenant.Do.bind(:fromTransaction, DebitTransaction) do |ctx|
        { fromAccount: ctx[:toAccount], toAccount: ctx[:fromAccount], amount: ctx[:amount] }
      end,
      Covenant.Do.bind(:toTransaction, CreditTransaction) { %i[fromAccount toAccount amount] },
      Covenant.Do.bind(:transfer, CreateTransfer) { %i[fromTransaction toTransaction amount] },
      Covenant.Do.map(&:transfer)
    )

    MoveMoney2 = Covenant.Compose(
      :move_money,
      { CreateTransferPayload => CreateTransferResult },
      [CheckBalance, DebitTransaction, CreditTransaction, CreateTransfer]
    ) do |handlers, input|
      handlers => { credit_transaction:, debit_transaction:, create_transfer:, check_balance: }
      input => { from_account:, to_account:, amount: }

      check_balance.call(account: from_account)

      from_transaction = credit_transaction.call(
        from_account: to_account,
        to_account: from_account,
        amount: amount
      )
      to_transaction = debit_transaction.call(
        from_account: from_account,
        to_account: to_account,
        amount: amount
      )
      create_transfer.call(from_transaction:, to_transaction:, amount:)
    end
  end
end
