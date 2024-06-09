import 'package:flutter/material.dart';
import 'package:gestao_hotelaria/sql_helper.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _refreshTickets() async {
    try {
      final data = await SQLHelper.getTickets();
      setState(() {
        _tickets = data;
        _isLoading = false;
      });
      print("Num tickets: ${_tickets.length}");
    } catch (e) {
      print("Error refreshing tickets: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTicket() async {
    await SQLHelper.createTicket(
        _descriptionController.text, double.parse(_priceController.text));
    _refreshTickets();
  }

  Future<void> _updateTicket(int id) async {
    await SQLHelper.updateTicket(
        id, _descriptionController.text, double.parse(_priceController.text));
    _refreshTickets();
  }

  Future<void> _deleteTicket(int id) async {
    await SQLHelper.deleteTicket(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bilhete apagado com sucesso!'),
        duration: Duration(seconds: 2),
      ),
    );
    _refreshTickets();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingTicket =
          _tickets.firstWhere((element) => element['id'] == id);
      _descriptionController.text = existingTicket['description'];
      _priceController.text = existingTicket['price'].toString();
    } else {
      _descriptionController.clear();
      _priceController.clear();
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
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Preço'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addTicket();
                } else {
                  await _updateTicket(id);
                }
                _descriptionController.clear();
                _priceController.clear();
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Adicionar' : 'Atualizar'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshTickets();
    print("Num ${_tickets.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilhetes'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tickets.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(_tickets[index]['description']),
                  subtitle: Text('Preço: \$${_tickets[index]['price']}'),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(_tickets[index]['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTicket(_tickets[index]['id']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
