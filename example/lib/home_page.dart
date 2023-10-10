import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/widgets/session_widget.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/chain_data_wrapper.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/helpers.dart';
import 'package:walletconnect_flutter_dapp/utils/dart_defines.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';
import 'package:walletconnect_flutter_dapp/widgets/event_widget.dart';

// TODO a refactor of the whole example app must be performed
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.swapTheme});
  final void Function() swapTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IWeb3App? _web3App;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _web3App = Web3App(
      core: Core(projectId: DartDefines.projectId),
      metadata: const PairingMetadata(
        name: 'Flutter Dapp Example',
        description: 'Flutter Dapp Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );

    _web3App!.onSessionPing.subscribe(_onSessionPing);
    _web3App!.onSessionEvent.subscribe(_onSessionEvent);

    await _web3App!.init();

    // Loop through all the chain data
    for (final ChainMetadata chain in ChainDataWrapper.chains) {
      // Loop through the events for that chain
      for (final event in getChainEvents(chain.type)) {
        _web3App!.registerEventHandler(
          chainId: chain.w3mChainInfo.namespace,
          event: event,
          handler: null,
        );
      }
    }

    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _web3App!.onSessionPing.unsubscribe(_onSessionPing);
    _web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          color: Web3ModalTheme.colorsOf(context).accent100,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Web3ModalTheme.colorsOf(context).background300,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(StringConstants.w3mPageTitleV3),
        backgroundColor: Web3ModalTheme.colorsOf(context).background100,
        foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
        actions: [
          IconButton(
            icon: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
            onPressed: widget.swapTheme,
          ),
        ],
      ),
      body: _W3MPage(web3App: _web3App!),
    );
  }

  void _onSessionPing(SessionPing? args) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return EventWidget(
            title: StringConstants.receivedPing,
            content: 'Topic: ${args!.topic}',
          );
        },
      );

  void _onSessionEvent(SessionEvent? args) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return EventWidget(
            title: StringConstants.receivedEvent,
            content: 'Topic: ${args!.topic}\n'
                'Event Name: ${args.name}\n'
                'Event Data: ${args.data}',
          );
        },
      );
}

class _W3MPage extends StatefulWidget {
  const _W3MPage({required this.web3App});
  final IWeb3App web3App;

  @override
  State<_W3MPage> createState() => _W3MPageState();
}

class _W3MPageState extends State<_W3MPage> {
  late IWeb3App _web3App;
  late W3MService _w3mService;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _web3App = widget.web3App;
    _web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);

    _initializeService();
  }

  void _initializeService() async {
    _w3mService = W3MService(
      web3App: _web3App,
      recommendedWalletIds: {
        '19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927',
        'e9ff15be73584489ca4a66f64d32c4537711797e30b6660dbcb71ea72a42b1f4',
        '0b415a746fb9ee99cce155c2ceca0c6f6061b1dbca2d722b3ba16381d0562150',
      },
      // includedWalletIds: {
      //   'ecc4036f814562b41a5268adc86270fba1365471402006302e70169465b7ac18',
      //   '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369',
      //   '19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927',
      //   'e9ff15be73584489ca4a66f64d32c4537711797e30b6660dbcb71ea72a42b1f4',
      //   '225affb176778569276e484e1b92637ad061b01e13a048b35a9d280c3b58970f',
      //   '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0',
      //   'c03dfee351b6fcc421b4494ea33b9d4b92a984f87aa76d1663bb28705e95034a',
      //   'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
      //   '971e689d0a5be527bac79629b4ee9b925e82208e5168b733496a09c0faed0709',
      //   '0b415a746fb9ee99cce155c2ceca0c6f6061b1dbca2d722b3ba16381d0562150',
      // },
    );

    await _w3mService.init();

    setState(() {
      _isConnected = _web3App.sessions.getAll().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _web3App.onSessionConnect.unsubscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.unsubscribe(_onWeb3AppDisconnect);
    super.dispose();
  }

  void _onWeb3AppConnect(SessionConnect? args) {
    // If we connect, default to barebones
    setState(() {
      _isConnected = true;
    });
  }

  void _onWeb3AppDisconnect(SessionDelete? args) {
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox.square(dimension: 8.0),
          Visibility(
            visible: !_isConnected,
            child: W3MNetworkSelectButton(service: _w3mService),
          ),
          W3MConnectWalletButton(service: _w3mService),
          const SizedBox.square(dimension: 8.0),
          const Divider(height: 0.0),
          Visibility(
            visible: _isConnected,
            child: _ConnectedView(w3mService: _w3mService),
          )
        ],
      ),
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(dimension: 12.0),
        W3MAccountButton(service: w3mService),
        SessionWidget(
          session: w3mService.web3App!.sessions.getAll().first,
          web3App: w3mService.web3App!,
          launchRedirect: () {
            w3mService.launchConnectedWallet();
          },
        ),
        const SizedBox.square(dimension: 12.0),
      ],
    );
  }
}
