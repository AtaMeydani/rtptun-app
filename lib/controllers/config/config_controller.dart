import 'package:flutter/material.dart';
import 'package:rtptun_app/controllers/data/repo/repository.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';
import 'package:rtptun_app/views/edit_config_screen/custom_field.dart';
import 'package:rtptun_app/controllers/config/validation_mixin.dart';

import '../../models/vpn/vpn_model.dart';

class ConfigController with ChangeNotifier, ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  bool saving = false;

  late final _remarkFieldController = TextEditingController();
  late final _remarkField = CustomField(
    labelText: 'remark',
    hintText: 'remark',
    controller: _remarkFieldController,
  );

  late final _serverAddressFieldController = TextEditingController();
  late final _serverAddressField = CustomField(
    labelText: 'server address',
    hintText: 'address',
    controller: _serverAddressFieldController,
  );

  late final _serverPortFieldController = TextEditingController();
  late final _serverPortField = CustomField(
    labelText: 'server port',
    hintText: 'port',
    controller: _serverPortFieldController,
    textInputType: TextInputType.number,
    validator: validatePortNumber,
  );

  late final _listenAddressFieldController = TextEditingController();
  late final _listenAddressField = CustomField(
    labelText: 'listen address',
    hintText: 'address',
    controller: _listenAddressFieldController,
  );

  late final _listenPortFieldController = TextEditingController();
  late final _listenPortField = CustomField(
    labelText: 'listen port',
    hintText: 'port',
    controller: _listenPortFieldController,
    textInputType: TextInputType.number,
    validator: validatePortNumber,
  );

  late final _secretKeyFieldController = TextEditingController();
  late final _secretKeyField = CustomField(
    labelText: 'encryption key',
    hintText: 'key',
    controller: _secretKeyFieldController,
  );

  VPN vpnConfig;
  Repository repository;
  ConfigController({required this.repository, required this.vpnConfig});

  Future<bool> saveChanges() async {
    if (isValid) {
      saving = true;
      notifyListeners();
      switch (vpnConfig.runtimeType) {
        case RTP:
          RTP rtpConfig = vpnConfig as RTP;
          rtpConfig.remark = _remarkFieldController.text;
          rtpConfig.serverAddress = _serverAddressFieldController.text;
          rtpConfig.serverPort = _serverPortFieldController.text;
          rtpConfig.listenAddress = _listenAddressFieldController.text;
          rtpConfig.listenPort = _listenPortFieldController.text;
          rtpConfig.secretKey = _secretKeyFieldController.text;
          await repository.createOrUpdate(rtpConfig);
      }

      saving = false;
      notifyListeners();

      return true;
    }
    return false;
  }

  void delete() async {
    await repository.delete(vpnConfig);
  }

  ({String title, String subtitle, VPN config}) getConfigListTileInfo(int index) {
    final VPN config = repository.getConfigByIndex(index);

    if (config is RTP) {
      return (title: config.remark ?? '', subtitle: '${config.serverAddress} : ${config.serverPort}', config: config);
    }

    return (title: 'unknown config', subtitle: 'unknown config', config: RTP());
  }

  GlobalKey<FormState> get formKey => _formKey;

  bool get isValid => _formKey.currentState!.validate();

  List<Widget> get fields {
    switch (vpnConfig.runtimeType) {
      case RTP:
        RTP rtp = vpnConfig as RTP;
        _remarkFieldController.text = rtp.remark ?? 'NewRTPConfig';
        _serverAddressFieldController.text = rtp.serverAddress ?? '';
        _serverPortFieldController.text = rtp.serverPort ?? '';
        _listenAddressFieldController.text = rtp.listenAddress ?? '0.0.0.0';
        _listenPortFieldController.text = rtp.listenPort ?? '';
        _secretKeyFieldController.text = rtp.secretKey ?? '';
        return [
          _remarkField,
          _serverAddressField,
          _serverPortField,
          _listenAddressField,
          _listenPortField,
          _secretKeyField,
        ];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _remarkFieldController.dispose();
    _serverAddressFieldController.dispose();
    _serverPortFieldController.dispose();
    _listenAddressFieldController.dispose();
    _listenPortFieldController.dispose();

    super.dispose();
  }
}
