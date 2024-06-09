import 'package:flutter/material.dart';
import 'package:gestao_hotelaria/sql_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotelaria',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hotelaria'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _refreshClient() async {
    try {
      final data = await SQLHelper.getClients();
      setState(() {
        _clients = data;
        _isLoading = false;
      });
      print("Num clients: ${_clients.length}");
    } catch (e) {
      print("Error refreshing clients: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addClient() async {
    await SQLHelper.createClient(_nameController.text, _emailController.text);
    _refreshClient();
  }

  Future<void> _updateClient(int id) async {
    await SQLHelper.updateClient(
        id, _nameController.text, _emailController.text);
    _refreshClient();
  }

  Future<void> _deleteClient(int id) async {
    await SQLHelper.deleteClient(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cliente apagado com sucesso!'),
        duration: Duration(seconds: 2),
      ),
    );
    _refreshClient();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingClient =
          _clients.firstWhere((element) => element['id'] == id);
      _nameController.text = existingClient['name'];
      _emailController.text = existingClient['email'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addClient();
                      }
                      if (id != null) {
                        await _updateClient(id);
                      }
                      _nameController.clear();
                      _emailController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Adicionar' : 'Atualizar'),
                  )
                ],
              ),
            ));
  }

  @override
  void initState() {
    super.initState();
    _refreshClient();
    print("Num ${_clients.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showForm(null),
        ),
        body: ListView.builder(
          itemCount: _clients.length,
          itemBuilder: (context, index) => Card(
              color: Colors.orange[200],
              margin: EdgeInsets.all(15),
              child: ListTile(
                  title: Text(_clients[index]['name']),
                  subtitle: Text(_clients[index]['email']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(_clients[index]['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteClient(_clients[index]['id']),
                        ),
                      ],
                    ),
                  ))),
        ));
  }
}
