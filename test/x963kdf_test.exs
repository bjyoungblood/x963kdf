defmodule X963KDFTest do
  use ExUnit.Case

  @nist_vectors_file "test/fixtures/ansx963_2001.rsp"

  test "NIST vectors" do
    for %{params: params, cases: cases} <- load_vectors(),
        %{alg: alg, key_len: key_len} = params,
        %{
          shared_secret: shared_secret,
          shared_info: shared_info,
          expected_output: expected_output
        } = test_case <- cases do
      output = X963KDF.derive(alg, shared_secret, div(key_len, 8), shared_data: shared_info)

      assert output == expected_output,
             """
             Case parameters: #{inspect(params)}

             Inputs:
             COUNT = #{test_case.index}
             Z = #{Base.encode16(shared_secret, case: :lower)}
             SharedInfo = #{Base.encode16(shared_info, case: :lower)}

             Expected Output: #{Base.encode16(expected_output, case: :lower)}
             Actual Output:   #{Base.encode16(output, case: :lower)}
             """
    end
  end

  defp load_vectors() do
    stream = File.stream!(@nist_vectors_file, [:read])

    chunk_fun = fn element, acc ->
      if element =~ ~r/^\[SHA-\d+\]$/i do
        {:cont, acc, [element]}
      else
        {:cont, acc ++ [element]}
      end
    end

    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, acc, []}
    end

    stream
    # Remove newlines
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    # Reject comments
    |> Stream.reject(&String.starts_with?(&1, "#"))
    # Chunk into test cases grouped by algorithm parameters
    |> Stream.chunk_while([], chunk_fun, after_fun)
    # Reject empty chunks
    |> Stream.reject(&(&1 == [] || &1 == [""]))
    # Parse the test cases
    |> Stream.map(fn block ->
      {params, rest} =
        block
        |> Enum.reject(&(&1 == ""))
        |> Enum.split(4)

      [
        alg,
        "[shared secret length = " <> shared_secret_len,
        "[SharedInfo length = " <> shared_info_len,
        "[key data length = " <> key_len
      ] = params

      alg =
        case alg do
          "[SHA-1]" -> :sha
          "[SHA-224]" -> :sha224
          "[SHA-256]" -> :sha256
          "[SHA-384]" -> :sha384
          "[SHA-512]" -> :sha512
          _ -> raise "unhandled algorithm: #{inspect(alg)}"
        end

      [shared_secret_len, shared_info_len, key_len] =
        Enum.map([shared_secret_len, shared_info_len, key_len], fn line ->
          {v, "]"} = Integer.parse(line)
          v
        end)

      cases =
        rest
        |> Enum.chunk_every(4)
        |> Enum.map(fn [
                         "COUNT = " <> index,
                         "Z = " <> shared_secret,
                         "SharedInfo = " <> shared_info,
                         "key_data = " <> expected_output
                       ] ->
          %{
            index: index,
            shared_secret: hex_to_raw(shared_secret),
            shared_info: hex_to_raw(shared_info),
            expected_output: hex_to_raw(expected_output)
          }
        end)

      %{
        params: %{
          alg: alg,
          shared_secret_len: shared_secret_len,
          shared_info_len: shared_info_len,
          key_len: key_len
        },
        cases: cases
      }
    end)
    |> Enum.into([])
  end

  defp hex_to_raw(""), do: ""
  defp hex_to_raw(binary), do: binary |> String.trim() |> Base.decode16!(case: :lower)
end
