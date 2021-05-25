enum EstadoCampaniaEnum { EN_CURSO, TERMINADO }

class EstadoCampania {
  static int getValue(EstadoCampaniaEnum texto) {
    return [31, 32][texto.index];
  }
}
