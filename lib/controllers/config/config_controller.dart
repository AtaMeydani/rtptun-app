import 'package:flutter/material.dart';
import 'package:rtptun_app/models/open_vpn/openvpn_model.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';
import 'package:rtptun_app/models/vpn/vpn_model.dart';
import 'package:rtptun_app/views/edit_config_screen/custom_field.dart';

import '../data/repo/repository.dart';
import 'validation_mixin.dart';

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
    validator: notEmpty,
  );

  late final _serverPortFieldController = TextEditingController();
  late final _serverPortField = CustomField(
    labelText: 'server port',
    hintText: 'port',
    controller: _serverPortFieldController,
    textInputType: TextInputType.number,
    validator: validatePortNumber,
  );

  late final _localAddressFieldController = TextEditingController();
  late final _localAddressField = CustomField(
    labelText: 'local address',
    hintText: 'address',
    controller: _localAddressFieldController,
    validator: notEmpty,
  );

  late final _localPortFieldController = TextEditingController();
  late final _localPortField = CustomField(
    labelText: 'local port',
    hintText: 'port',
    controller: _localPortFieldController,
    textInputType: TextInputType.number,
    validator: validatePortNumber,
  );

  late final _secretKeyFieldController = TextEditingController();
  late final _secretKeyField = CustomField(
    labelText: 'encryption key',
    hintText: 'key',
    controller: _secretKeyFieldController,
    validator: notEmpty,
  );

  late final _vpnConfigFieldController = TextEditingController();
  late final _vpnConfigField = CustomField(
    textInputType: TextInputType.multiline,
    labelText: 'openvpn config',
    hintText: 'config',
    controller: _vpnConfigFieldController,
    validator: notEmpty,
  );

  late final _vpnUsernameFieldController = TextEditingController();
  late final _vpnUsernameField = CustomField(
    labelText: 'openvpn username',
    hintText: 'username',
    controller: _vpnUsernameFieldController,
  );

  late final _vpnPasswordFieldController = TextEditingController();
  late final _vpnPasswordField = CustomField(
    labelText: 'openvpn password',
    hintText: 'password',
    controller: _vpnPasswordFieldController,
  );

  Tunnel? tunnel;
  VPN? vpn;
  Repository repository;
  ConfigController({required this.repository, this.tunnel}) {
    vpn = tunnel?.vpn;
  }

  void changeSelectedTunnel(Tunnel? tunnel) {
    this.tunnel = tunnel;
    notifyListeners();
  }

  void changeSelectedVPN(VPN? vpn) {
    this.vpn = vpn;
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    if (isValid) {
      saving = true;
      notifyListeners();

      if (tunnel != null) {
        _saveTunnelObject(tunnel!);
        _saveVPNObject(vpn);
        tunnel!.vpn = vpn;
        await repository.createOrUpdate(tunnel!);
        saving = false;
        notifyListeners();
        return true;
      } else {
        saving = false;
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  _saveTunnelObject(Tunnel tunnel) {
    switch (tunnel.runtimeType) {
      case RTP:
        RTP rtpConfig = tunnel as RTP;
        rtpConfig.remark = _remarkFieldController.text;
        rtpConfig.serverAddress = _serverAddressFieldController.text;
        rtpConfig.serverPort = _serverPortFieldController.text;
        rtpConfig.localAddress = _localAddressFieldController.text;
        rtpConfig.localPort = _localPortFieldController.text;
        rtpConfig.secretKey = _secretKeyFieldController.text;
        break;
      default:
    }
  }

  _saveVPNObject(VPN? vpn) {
    switch (vpn.runtimeType) {
      case OpenVPNModel:
        OpenVPNModel openvpn = vpn as OpenVPNModel;
        openvpn.config = _vpnConfigFieldController.text;
        openvpn.username = _vpnUsernameFieldController.text;
        openvpn.password = _vpnPasswordFieldController.text;
        break;
      default:
    }
  }

  void delete() async {
    await repository.delete(tunnel);
  }

  ({String title, String subtitle, Tunnel config}) getTunnelListTileInfo(int index) {
    final Tunnel config = repository.getTunnelByIndex(index);

    if (config is RTP) {
      return (title: config.remark ?? '', subtitle: '${config.serverAddress} : ${config.serverPort}', config: config);
    }

    return (title: 'unknown config', subtitle: 'unknown config', config: RTP());
  }

  GlobalKey<FormState> get formKey => _formKey;

  bool get isValid => _formKey.currentState!.validate();

  List<Widget> get tunnelFields {
    switch (tunnel.runtimeType) {
      case RTP:
        RTP rtp = tunnel as RTP;
        _remarkFieldController.text = rtp.remark ?? 'NewRTPConfig';
        _serverAddressFieldController.text = rtp.serverAddress ?? '';
        _serverPortFieldController.text = rtp.serverPort ?? '';
        _localAddressFieldController.text = rtp.localAddress ?? '127.0.0.1';
        _localPortFieldController.text = rtp.localPort ?? '';
        _secretKeyFieldController.text = rtp.secretKey ?? '';
        return [
          _remarkField,
          _serverAddressField,
          _serverPortField,
          _localAddressField,
          _localPortField,
          _secretKeyField,
        ];
      default:
        return [];
    }
  }

  List<Widget> get vpnFields {
    switch (vpn.runtimeType) {
      case OpenVPNModel:
        OpenVPNModel openvpn = vpn as OpenVPNModel;
        _vpnConfigFieldController.text = openvpn.config ?? '';
        _vpnUsernameFieldController.text = openvpn.username ?? '';
        _vpnPasswordFieldController.text = openvpn.password ?? '';
        return [
          _vpnConfigField,
          _vpnUsernameField,
          _vpnPasswordField,
        ];
      default:
        // vpn is null
        return [];
    }
  }

  @override
  void dispose() {
    _remarkFieldController.dispose();
    _serverAddressFieldController.dispose();
    _serverPortFieldController.dispose();
    _localAddressFieldController.dispose();
    _localPortFieldController.dispose();
    _vpnConfigFieldController.dispose();
    _vpnUsernameFieldController.dispose();
    _vpnPasswordFieldController.dispose();

    super.dispose();
  }
}
