defmodule Extractly.DoNotEditWarningTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  describe "known locales" do 
   
    @default_message """
    <!--
    DO NOT EDIT THIS FILE
    It has been generated from a template by Extractly (https://github.com/RobertDober/extractly.git)
    and any changes you make in this file will most likely be lost
    -->
    """
    test "default behaviour" do
      result = Extractly.do_not_edit_warning

      assert result == @default_message |> String.trim_trailing
    end

    @message_with_template """
    <!--
    DO NOT EDIT THIS FILE
    It has been generated from the template `shiny_new_template` by Extractly (https://github.com/RobertDober/extractly.git)
    and any changes you make in this file will most likely be lost
    -->
    """
    test "with template" do
      result = Extractly.do_not_edit_warning template: "shiny_new_template"

      assert result == @message_with_template |> String.trim_trailing
    end

    @french_message """
    <!--
    NE PAS EDITER CE FICHIER
    Il a été créé à partir d'un patron par Extractly (https://github.com/RobertDober/extractly.git)
    et toute modification apportée par vos soins va probablement être perdue
    -->
    """
    test "french message" do
      result = Extractly.do_not_edit_warning lang: :fr

      assert result == @french_message |> String.trim_trailing
    end

    @french_complex_message """
    /*
    NE PAS EDITER CE FICHIER
    Il a été créé à partir du patron `mon_fichier` par Extractly (https://github.com/RobertDober/extractly.git)
    et toute modification apportée par vos soins va probablement être perdue
    */
    """
    test "french complex message" do
      result = Extractly.do_not_edit_warning lang: :fr, template: "mon_fichier", comment_start: "/*\n", comment_end: "*/"

      assert result == @french_complex_message |> String.trim_trailing
    end
  end

  describe "fall back to english" do
    test "for chinese" do
      
      stderr = capture_io(:stderr, fn ->
        result = Extractly.do_not_edit_warning lang: :zn

        assert result == @default_message |> String.trim_trailing
      end)
      assert stderr == "Language zn is not supported yet, falling back to :en\n"
    end
  end
end