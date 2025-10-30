defmodule Pieza do
  defstruct [:codigo, :nombre, :valor, :unidad, :stock]

  @type t :: %__MODULE__{
          codigo: String.t(),
          nombre: String.t(),
          valor: integer(),
          unidad: String.t(),
          stock: integer()
        }

  def parse_line(line) do
    case String.split(line, ",") do
      [codigo, nombre, valor_str, unidad, stock_str] ->
        with {:ok, valor} <- parse_integer(valor_str),
             {:ok, stock} <- parse_integer(stock_str) do
          {:ok, %__MODULE__{codigo: codigo, nombre: nombre, valor: valor, unidad: unidad, stock: stock}}
        else
          error -> error
        end

      _ ->
        {:error, "Formato inválido: #{line}"}
    end
  end

  defp parse_integer(str) do
    case Integer.parse(String.trim(str)) do
      {num, ""} -> {:ok, num}
      _ -> {:error, "Número inválido: #{str}"}
    end
  end

  # 1B: Contar piezas con stock < t (recursivo)
  def contar_stock_bajo(piezas, umbral) when is_list(piezas) and is_integer(umbral) do
    contar_stock_bajo_rec(piezas, umbral, 0)
  end

  defp contar_stock_bajo_rec([], _umbral, count), do: count

  defp contar_stock_bajo_rec([pieza | rest], umbral, count) do
    new_count = if pieza.stock < umbral, do: count + 1, else: count
    contar_stock_bajo_rec(rest, umbral, new_count)
  end

  # 4: Eliminar duplicados por código (recursivo)
  def eliminar_duplicados(piezas) when is_list(piezas) do
    eliminar_duplicados_rec(piezas, MapSet.new(), [])
  end

  defp eliminar_duplicados_rec([], _vistos, resultado), do: Enum.reverse(resultado)

  defp eliminar_duplicados_rec([pieza | rest], vistos, resultado) do
    if MapSet.member?(vistos, pieza.codigo) do
      eliminar_duplicados_rec(rest, vistos, resultado)
    else
      nuevos_vistos = MapSet.put(vistos, pieza.codigo)
      eliminar_duplicados_rec(rest, nuevos_vistos, [pieza | resultado])
    end
  end
end
