enum EstadoEnum { PENDIENTE, CANCELADO, ANULADO }

class Estado {
  static int getValue(EstadoEnum texto) {
    return [11, 12, 13][texto.index];
  }
}
