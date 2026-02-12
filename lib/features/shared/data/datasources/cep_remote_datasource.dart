import 'package:dio/dio.dart';
import '../models/address_model.dart';

class CepRemoteDatasource {
  final Dio _apiDio;

  CepRemoteDatasource(this._apiDio);

  /// Busca endereço via backend (inclui geocoding)
  Future<AddressModel> lookupCepViaBackend(String cep) async {
    final response = await _apiDio.post('/geocoding/cep', data: {
      'cep': cep,
    });
    return AddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Busca endereço via ViaCEP (fallback externo)
  Future<AddressModel> lookupCepViaViaCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    final viaCepDio = Dio();
    final response = await viaCepDio.get(
      'https://viacep.com.br/ws/$cleanCep/json/',
    );

    final data = response.data as Map<String, dynamic>;

    if (data.containsKey('erro') && data['erro'] == true) {
      throw Exception('CEP não encontrado');
    }

    return AddressModel(
      cep: data['cep'] as String? ?? cleanCep,
      street: data['logradouro'] as String? ?? '',
      number: '',
      neighborhood: data['bairro'] as String? ?? '',
      city: data['localidade'] as String? ?? '',
      state: data['uf'] as String? ?? '',
    );
  }

  /// Busca CEP com fallback: tenta backend primeiro, depois ViaCEP
  Future<AddressModel> lookupCep(String cep) async {
    try {
      return await lookupCepViaBackend(cep);
    } catch (_) {
      return await lookupCepViaViaCep(cep);
    }
  }
}
