defmodule Tcc.Logger.Formatter do
  @moduledoc false

  @spec format(Logger.level(), any(), Logger.Formatter.time(), keyword()) :: String.t()
  def format(level, message, timestamp, metadata) do
    data = %{
      "severity" => level,
      "message" => to_string(message),
      "@timestamp" => fmt_timestamp(timestamp),
      "dd.trace_id" => to_string(metadata[:trace_id])
    }

    out =
      metadata
      |> Keyword.drop([:file, :line, :module, :function, :application, :pid])
      |> Enum.map(&fmt_metadata/1)
      |> Enum.into(data)
      |> Jason.encode!()

    out <> "\n"
  rescue
    error ->
      "could not format message: #{inspect({level, message, timestamp, metadata})}, error: #{
        inspect(error)
      }\n"
  end

  defp fmt_timestamp({date, {hh, mm, ss, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}, {ms * 1000, 3}),
         result <- NaiveDateTime.to_iso8601(timestamp) do
      "#{result}Z"
    end
  end

  defp fmt_metadata({k, v}) when is_binary(v), do: {k, v}
  defp fmt_metadata({k, v}), do: {k, inspect(v)}
end
