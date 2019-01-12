defmodule Support.Macro do
  @doc "I am a macro"
  defmacro i_am_a_macro do
    quote do
      def hello do
        42
      end
    end
  end
end
