import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MsLoginScreen extends StatefulWidget {
  const MsLoginScreen({Key? key}) : super(key: key);

  @override
  _MsLoginScreenState createState() => _MsLoginScreenState();
}

class _MsLoginScreenState extends State<MsLoginScreen> {
  late final Config config;
  late final AadOAuth oauth;
  String? _accessToken;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    config = Config(
      tenant: '8ce3519f-905a-46d5-998c-b7018db318fa', // <-- tu Tenant ID
      clientId: '0364ead2-1cd0-44c8-a5e9-968befab7513', // <-- tu Client ID
      scope: 'openid profile offline_access',
      redirectUri: 'msal0364ead2-1cd0-44c8-a5e9-968befab7513://auth', // <-- usa tu Client ID aquí también
      navigatorKey: navigatorKey,
    );
    oauth = AadOAuth(config);
  }

  void _login() async {
    try {
      await oauth.login();
      String? accessToken = await oauth.getAccessToken();
      setState(() {
        _accessToken = accessToken;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _accessToken = null;
      });
    }
  }

  void _logout() async {
    await oauth.logout();
    setState(() {
      _accessToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Microsoft Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_accessToken != null) ...[
              Text('Access Token:'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _accessToken!,
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _login,
                child: Text('Login with Microsoft'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}