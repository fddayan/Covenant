RSpec.describe Covenant::Ast::Ast do
  describe "#to_ast" do
    it "should return a valid AST for a schema" do
      id = Covenant.Scalar(:id, Covenant.Validate.coerce(:integer))
      name = Covenant.Scalar(:name, Covenant.Validate.coerce(:string))
      user = Covenant.Schema(:user, id + name)

      ast = Covenant::Ast::Ast.new(user).to_ast

      expect(ast).to be_a(Hash)
      expect(ast).to eq({:type=>:struct, :tag=>:user, :properties=>[:id, :name]})
    end

    it "should return a valid AST for a contract" do
      id = Covenant.Scalar(:id, Covenant.Validate.coerce(:integer))
      name = Covenant.Scalar(:name, Covenant.Validate.coerce(:string))
      user = Covenant.Schema(:user, id + name)
      contract = Covenant.Contract(:GetUser, id.struct, user)

      ast = Covenant::Ast::Ast.new(contract).to_ast

      expect(ast).to be_a(Hash)
      expect(ast).to eq(
       {
        :type => :contract, 
        :command => :GetUser, 
        :opts => {},
        :input => {
          :type => :struct, 
          :tag => :id, 
          :properties => [:id]
        }, 
        :output => {
          :type => :struct, 
          :tag => :user, 
          :properties => [:id, :name]
        }} 
      )
    end
  end
end