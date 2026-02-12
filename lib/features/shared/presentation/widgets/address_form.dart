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
    widget.onChanged(AddressModel(
      cep: _cepController.text,
      street: _streetController.text,
      number: _numberController.text,
      complement: _complementController.text.isEmpty ? null : _complementController.text,
      neighborhood: _neighborhoodController.text,
      city: _cityController.text,
      state: _stateController.text,
    ));
  }

  Future<void> _handleCepChange(String value) async {
    final masked = Masks.maskCep(value);
    _cepController.text = masked;
    _cepController.selection = TextSelection.fromPosition(
      TextPosition(offset: masked.length),
    );
    _emitChange();

    final digits = Masks.unmask(masked);
    if (digits.length == 8 && widget.cepDatasource != null) {
      setState(() => _loadingCep = true);
      try {
        final addr = await widget.cepDatasource!.lookupCep(digits);
        _streetController.text = addr.street;
        _neighborhoodController.text = addr.neighborhood;
        _cityController.text = addr.city;
        _stateController.text = addr.state;
        _emitChange();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CEP não encontrado')),
          );
        }
      } finally {
        if (mounted) setState(() => _loadingCep = false);
      }
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
                maxLength: 9,
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
