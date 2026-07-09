class CnpjSearchException implements Exception {
  CnpjSearchException(this.message);
  final String message;
}

class CnpjNotFoundException extends CnpjSearchException {
  CnpjNotFoundException() : super('CNPJ não encontrado');
}
