import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/utils/masks.dart';
import '../../data/models/address_model.dart';
import '../../data/datasources/cep_remote_datasource.dart';

class AddressForm extends StatefulWidget {
  final AddressModel address;
  final ValueChanged<AddressModel> onChanged;
  final CepRemoteDatasource? cepDatasource;

  const AddressForm({
    super.key,
    required this.address,
    required this.onChanged,
    this.cepDatasource,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  late TextEditingController _cepController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _complementController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  bool _loadingCep = false;
  final _cepFormatter = Masks.cep();

  @override
  void initState() {
    super.initState();
    _cepController = TextEditingController(text: widget.address.cep);
    _streetController = TextEditingController(text: widget.address.street);
    _numberController = TextEditingController(text: widget.address.number);
    _complementController = TextEditingController(text: widget.address.complement ?? '');
    _neighborhoodController = TextEditingController(text: widget.address.neighborhood);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
  }

  @override
  void didUpdateWidget(AddressForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Só atualizamos se o endereço mudou substancialmente (ex: vindo de fora)
    // e o usuário não está digitando no campo de CEP
    if (widget.address != oldWidget.address && !_loadingCep) {
      if (_cepController.text != widget.address.cep) {
        _cepController.text = widget.address.cep;
      }
      if (_streetController.text != widget.address.street) {
        _streetController.text = widget.address.street;
      }
      if (_numberController.text != widget.address.number) {
        _numberController.text = widget.address.number;
      }
      if (_complementController.text != (widget.address.complement ?? '')) {
        _complementController.text = widget.address.complement ?? '';
      }
      if (_neighborhoodController.text != widget.address.neighborhood) {
        _neighborhoodController.text = widget.address.neighborhood;
      }
      if (_cityController.text != widget.address.city) {
        _cityController.text = widget.address.city;
      }
      if (_stateController.text != widget.address.state) {
        _stateController.text = widget.address.state;
      }
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _emitChange() {
    // Preservamos o ID e coordenadas originais
    widget.onChanged(widget.address.copyWith(
      cep: _cepController.text,
      street: _streetController.text,
      number: _numberController.text,
      complement:
          _complementController.text.isEmpty ? null : _complementController.text,
      neighborhood: _neighborhoodController.text,
      city: _cityController.text,
      state: _stateController.text,
    ));
  }

  Future<void> _handleCepChange(String value) async {
    final digits = Masks.unmask(value);
    if (digits.length == 8 && widget.cepDatasource != null) {
      setState(() => _loadingCep = true);
      try {
        final addr = await widget.cepDatasource!.lookupCep(digits);

        // Atualizamos os controllers internos
        setState(() {
          _streetController.text = addr.street;
          _neighborhoodController.text = addr.neighborhood;
          _cityController.text = addr.city;
          _stateController.text = addr.state;
        });

        // Notificamos o pai imediatamente com o novo endereço completo
        // Mantendo o número que já pode ter sido digitado
        widget.onChanged(widget.address.copyWith(
          cep: addr.cep,
          street: addr.street,
          neighborhood: addr.neighborhood,
          city: addr.city,
          state: addr.state,
          latitude: addr.latitude,
          longitude: addr.longitude,
          number: _numberController.text,
        ));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CEP não encontrado')),
          );
        }
      } finally {
        if (mounted) setState(() => _loadingCep = false);
      }
    } else {
      // Se noca for mudança de digits completas, apenas emitimos a alteração normal do campo
      _emitChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppInput(
                label: 'CEP *',
                controller: _cepController,
                onChanged: _handleCepChange,
                hintText: '00000-000',
                keyboardType: TextInputType.number,
                inputFormatters: [_cepFormatter],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 100,
              child: AppInput(
                label: 'Número *',
                controller: _numberController,
                onChanged: (_) => _emitChange(),
                hintText: '123',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        if (_loadingCep)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: LinearProgressIndicator(),
          ),
        AppInput(
          label: 'Rua *',
          controller: _streetController,
          onChanged: (_) => _emitChange(),
          hintText: 'Nome da rua',
          readOnly: _loadingCep,
        ),
        AppInput(
          label: 'Complemento',
          controller: _complementController,
          onChanged: (_) => _emitChange(),
          hintText: 'Apto, bloco (opcional)',
        ),
        AppInput(
          label: 'Bairro *',
          controller: _neighborhoodController,
          onChanged: (_) => _emitChange(),
          hintText: 'Nome do bairro',
          readOnly: _loadingCep,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppInput(
                label: 'Cidade *',
                controller: _cityController,
                onChanged: (_) => _emitChange(),
                hintText: 'Cidade',
                readOnly: _loadingCep,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppInput(
                label: 'Estado *',
                controller: _stateController,
                onChanged: (_) => _emitChange(),
                hintText: 'SP',
                maxLength: 2,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  UpperCaseTextFormatter(),
                ],
                readOnly: _loadingCep,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
