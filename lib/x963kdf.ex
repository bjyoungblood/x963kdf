defmodule X963KDF do
  @moduledoc """
  ANSI X9.63 Key Derivation Function (KDF)
  """

  @type alg :: :crypto.sha1() | :crypto.sha2()

  @supported_algs [:sha, :sha224, :sha256, :sha384, :sha512]

  @doc """
  Derive a key from a shared secret using the ANSI X9.63 Key Derivation Function (KDF).

  ## Parameters

  * `alg` - the SHA-1 or SHA-2 hash function to use
  * `shared_secret` - the shared secret
  * `key_length` - the length of the derived key in bytes
  * `opts` - additional options
    * `:shared_data` - additional shared data to include in the key derivation
  """
  def derive(alg, shared_secret, key_length, opts \\ []) when alg in @supported_algs do
    shared_data = Keyword.get(opts, :shared_data, <<>>)

    hashmaxlen = hashmaxlen(alg)
    hashlen = hashlen(alg)

    cond do
      byte_size(shared_secret) + byte_size(shared_data) + 4 >= hashmaxlen ->
        raise ArgumentError,
              "shared_secret + shared_data + 4 must be less than #{hashmaxlen} bytes"

      key_length >= hashlen * (2 ** 32 - 1) ->
        raise ArgumentError, "key_length must be less than #{hashlen * (2 ** 32 - 1)}"

      true ->
        :ok
    end

    for counter <- 1..ceil(key_length / hashlen)//1, into: <<>> do
      :crypto.hash(
        alg,
        <<shared_secret::binary, counter::big-32, shared_data::binary>>
      )
    end
    |> binary_slice(0, key_length)
  end

  defp hashlen(:sha), do: 20
  defp hashlen(:sha224), do: 28
  defp hashlen(:sha256), do: 32
  defp hashlen(:sha384), do: 48
  defp hashlen(:sha512), do: 64

  defp hashmaxlen(alg) when alg in [:sha, :sha224, :sha256], do: 2 ** 61 - 1
  defp hashmaxlen(alg) when alg in [:sha384, :sha512], do: 2 ** 125 - 1
end
