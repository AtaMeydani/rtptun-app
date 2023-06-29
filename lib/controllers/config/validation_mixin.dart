mixin ValidationMixin {
  String? validatePortNumber(String? port) {
    RegExp regExp = RegExp(r'^[0-9]{1,5}$');
    if (!regExp.hasMatch(port ?? '')) {
      return 'Please Enter a valid port number';
    }
    int portNumber = int.parse(port ?? '');
    if (portNumber < 0 || portNumber > 65535) {
      return 'Port number must be in range 0, 65535';
    }
    return null;
  }

  String? notEmpty(String? value) {
    if (value == null || value == '') {
      return 'Please Enter A Value';
    }

    return null;
  }
}
