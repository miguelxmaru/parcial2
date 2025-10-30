defmodule Movimiento do
  defstruct [:codigo, :tipo, :cantidad, :fecha]

  @type t :: %__MODULE__{
          codigo: String.t(),
          tipo: :entrada | :salida,
          cantidad: integer(),
          fecha: String.t()
        }

  def parse_line(line) do
    case String.split(line, ",") do
      [codigo, tipo_str, cantidad_str, fecha] ->
        with {:ok, tipo} <- parse_tipo(tipo_str),
             {:ok, cantidad} <- parse_cantidad(cantidad_str),
             {:ok, fecha_validada} <- validar_fecha(fecha) do
          {:ok, %__MODULE__{codigo: codigo, tipo: tipo, cantidad: cantidad, fecha: fecha_validada}}
        else
          error -> error
        end

      _ ->
        {:error, "Formato inválido: #{line}"}
    end
  end

  defp parse_tipo(tipo_str) do
    tipo_limpio = String.trim(tipo_str) |> String.upcase()

    case tipo_limpio do
      "ENTRADA" -> {:ok, :entrada}
      "SALIDA" -> {:ok, :salida}
      _ -> {:error, "Tipo inválido: #{tipo_str}"}
    end
  end

  defp parse_cantidad(cantidad_str) do
    case Integer.parse(String.trim(cantidad_str)) do
      {cantidad, ""} when cantidad > 0 -> {:ok, cantidad}
      {cantidad, ""} when cantidad <= 0 -> {:error, "Cantidad debe ser > 0: #{cantidad}"}
      _ -> {:error, "Cantidad inválida: #{cantidad_str}"}
    end
  end

  defp validar_fecha(fecha) do
    fecha_limpia = String.trim(fecha)

    case String.split(fecha_limpia, "-") do
      [anio, mes, dia] ->
        with {anio_num, ""} <- Integer.parse(anio),
             {mes_num, ""} <- Integer.parse(mes),
             {dia_num, ""} <- Integer.parse(dia) do
          if fecha_valida?(anio_num, mes_num, dia_num) do
            {:ok, fecha_limpia}
          else
            {:error, "Fecha inválida: #{fecha}"}
          end
        else
          _ -> {:error, "Fecha inválida: #{fecha}"}
        end

      _ ->
        {:error, "Formato de fecha inválido: #{fecha}"}
    end
  end

  defp fecha_valida?(anio, mes, dia) when anio >= 0 and mes >= 1 and mes <= 12 and dia >= 1 and dia <= 31 do
    # Validación básica de días por mes
    dias_por_mes = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    max_dias = Enum.at(dias_por_mes, mes - 1)
    dia <= max_dias
  end

  defp fecha_valida?(_, _, _), do: false

  # 3: Cantidad total movida en rango de fechas (recursivo)
  def cantidad_total_en_rango(movimientos, fecha_inicio, fecha_fin) when is_list(movimientos) do
    cantidad_total_en_rango_rec(movimientos, fecha_inicio, fecha_fin, 0)
  end

  defp cantidad_total_en_rango_rec([], _fecha_inicio, _fecha_fin, total), do: total

  defp cantidad_total_en_rango_rec([movimiento | rest], fecha_inicio, fecha_fin, total) do
    if fecha_en_rango?(movimiento.fecha, fecha_inicio, fecha_fin) do
      cantidad_total_en_rango_rec(rest, fecha_inicio, fecha_fin, total + movimiento.cantidad)
    else
      cantidad_total_en_rango_rec(rest, fecha_inicio, fecha_fin, total)
    end
  end

  defp fecha_en_rango?(fecha, inicio, fin) do
    fecha >= inicio and fecha <= fin
  end
end
