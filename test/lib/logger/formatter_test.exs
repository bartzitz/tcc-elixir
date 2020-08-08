defmodule Tcc.Logger.FormatterTest do
  use ExUnit.Case
  alias Tcc.Logger.Formatter
  doctest Tcc

  describe "format/4" do
    test "formats logs as JSON" do
      log =
        Formatter.format("info", "log message", timestamp(), meta1: "metadata", trace_id: "123")

      assert log ==
               ~s({"meta1":"metadata","trace_id":"123","@timestamp":"2016-05-24T13:26:08.100Z","dd.trace_id":"123","message":"log message","severity":"info"}\n)
    end

    test "formats non-string metadata" do
      log = Formatter.format("info", "log message", timestamp(), meta1: %{some: "data"})

      assert log ==
               ~s({"meta1":"%{some: \\\"data\\\"}","@timestamp":"2016-05-24T13:26:08.100Z","dd.trace_id":"","message":"log message","severity":"info"}\n)
    end

    test "does not crash on errors" do
      log = Formatter.format("info", "log message", "invalid time", [])

      assert log ==
               ~s(could not format message: {\"info\", \"log message\", \"invalid time\", []}, error: %FunctionClauseError{args: nil, arity: 1, clauses: nil, function: :fmt_timestamp, kind: nil, module: Tcc.Logger.Formatter}\n)
    end
  end

  def timestamp(), do: {{2016, 05, 24}, {13, 26, 08, 100}}
end
