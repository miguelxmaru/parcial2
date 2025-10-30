defmodule Inventario do
  alias Pieza
  alias Movimiento

  # 1A: Leer archivo de piezas
  def leer_piezas(archivo) do
    case File.read(archivo) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n", trim: true)
        procesar_lineas_piezas(lineas, [])

      {:error, razon} ->
        {:error, "No se pudo leer el archivo: #{razon}"}
    end
  end

  defp procesar_lineas_piezas([], piezas), do: {:ok, Enum.reverse(piezas)}

  defp procesar_lineas_piezas([linea | rest], piezas) do
    case Pieza.parse_line(linea) do
      {:ok, pieza} ->
        procesar_lineas_piezas(rest, [pieza | piezas])

      {:error, razon} ->
        {:error, razon}
    end
  end

  # 2A: Leer movimientos
  def leer_movimientos(archivo) do
    case File.read(archivo) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n", trim: true)
        procesar_lineas_movimientos(lineas, [])

      {:error, razon} ->
        {:error, "No se pudo leer el archivo: #{razon}"}
    end
  end

  defp procesar_lineas_movimientos([], movimientos), do: {:ok, Enum.reverse(movimientos)}

  defp procesar_lineas_movimientos([linea | rest], movimientos) do
    case Movimiento.parse_line(linea) do
      {:ok, movimiento} ->
        procesar_lineas_movimientos(rest, [movimiento | movimientos])

      {:error, razon} ->
        {:error, razon}
    end
  end

  # 2A: Aplicar movimientos al stock
  def aplicar_movimientos(piezas, movimientos) when is_list(piezas) and is_list(movimientos) do
    mapa_piezas = Enum.into(piezas, %{}, fn pieza -> {pieza.codigo, pieza} end)
    mapa_actualizado = aplicar_movimientos_rec(movimientos, mapa_piezas)
    Map.values(mapa_actualizado)
  end

  defp aplicar_movimientos_rec([], mapa_piezas), do: mapa_piezas

  defp aplicar_movimientos_rec([movimiento | rest], mapa_piezas) do
    pieza_actual = Map.get(mapa_piezas, movimiento.codigo)

    nueva_pieza =
      if pieza_actual do
        nuevo_stock =
          case movimiento.tipo do
            :entrada -> pieza_actual.stock + movimiento.cantidad
            :salida -> pieza_actual.stock - movimiento.cantidad
          end

        %{pieza_actual | stock: nuevo_stock}
      else
        # Si no existe la pieza, crear una nueva (solo para entradas)
        if movimiento.tipo == :entrada do
          %Pieza{
            codigo: movimiento.codigo,
            nombre: "Nueva",
            valor: 0,
            unidad: "unidad",
            stock: movimiento.cantidad
          }
        else
          nil
        end
      end

    nuevo_mapa =
      if nueva_pieza do
        Map.put(mapa_piezas, movimiento.codigo, nueva_pieza)
      else
        mapa_piezas
      end

    aplicar_movimientos_rec(rest, nuevo_mapa)
  end

  # 2B: Persistir inventario actual
  def guardar_inventario(piezas, archivo) do
    lineas = Enum.map(piezas, fn pieza ->
      "#{pieza.codigo},#{pieza.nombre},#{pieza.valor},#{pieza.unidad},#{pieza.stock}"
    end)

    contenido = Enum.join(lineas, "\n")

    case File.write(archivo, contenido) do
      :ok -> {:ok, "Inventario guardado en #{archivo}"}
      {:error, razon} -> {:error, "Error al guardar: #{razon}"}
    end
  end
end
