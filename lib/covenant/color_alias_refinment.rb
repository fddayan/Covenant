# frozen_string_literal: true

module ColorAliasRefinement
  refine String do
    def self.define_color(name, color)
      define_method("#{name}_text") do
        colorize(color)
      end
    end

    define_color :compositon, :yellow
    define_color :arrow,      :green
    define_color :symbols,    :red
    define_color :input,      :magenta
    define_color :output,     :magenta
    define_color :contract,   :blue
    define_color :result,     :green
    define_color :error,      :red
    define_color :success,    :green
    define_color :warning,    :yellow
    define_color :info,       :blue
    define_color :command,    :cyan
  end
end
