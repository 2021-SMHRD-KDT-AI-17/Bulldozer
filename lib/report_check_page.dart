import 'package:flutter/material.dart';

class Flavor {
  final String name;
  final bool isFavorite;

  Flavor({required this.name, this.isFavorite = false});

  Flavor copyWith({String? name, bool? isFavorite}) {
    return Flavor(
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ReportCheck extends StatefulWidget {
  const ReportCheck({super.key});

  @override
  _ReportCheckState createState() => _ReportCheckState();
}

class _ReportCheckState extends State<ReportCheck> {
  final List<Flavor> flavors = [
    Flavor(name: 'Chocolate'),
    Flavor(name: 'Strawberry'),
    Flavor(name: 'Hazelnut'),
    Flavor(name: 'Vanilla'),
    Flavor(name: 'Lemon'),
    Flavor(name: 'Yoghurt'),
  ];

  bool _isDeleteMode = false;
  final Set<int> _selectedIndices = Set<int>();

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _selectedIndices.clear();
    });
  }

  Future<void> _confirmDeleteSelected() async {
    final confirmed = await _showConfirmationDialog();
    if (confirmed) {
      setState(() {
        flavors.removeWhere((flavor) => _selectedIndices.contains(flavors.indexOf(flavor)));
        _selectedIndices.clear();
        _isDeleteMode = false;
      });
    }
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await _showConfirmationDialog();
    if (confirmed) {
      setState(() {
        flavors.clear();
      });
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('예'),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flavors'),
        actions: [
          IconButton(
            icon: Icon(_isDeleteMode ? Icons.delete : Icons.edit),
            onPressed: _isDeleteMode ? _confirmDeleteSelected : _toggleDeleteMode,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _confirmDeleteAll,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: flavors.length,
        itemBuilder: (context, index) {
          final flavor = flavors[index];
          return Dismissible(
            key: Key(flavor.name),
            background: Container(
              alignment: Alignment.centerLeft,
              color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            direction: DismissDirection.startToEnd,
            dismissThresholds: {DismissDirection.startToEnd: 0.25},
            onDismissed: (direction) {
              setState(() {
                flavors.removeAt(index);
              });
            },
            child: ListTile(
              leading: _isDeleteMode
                  ? Checkbox(
                value: _selectedIndices.contains(index),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedIndices.add(index);
                    } else {
                      _selectedIndices.remove(index);
                    }
                  });
                },
              )
                  : null,
              title: Text(flavor.name),
              trailing: Icon(flavor.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              onTap: () {
                if (_isDeleteMode) {
                  setState(() {
                    if (_selectedIndices.contains(index)) {
                      _selectedIndices.remove(index);
                    } else {
                      _selectedIndices.add(index);
                    }
                  });
                } else {
                  setState(() {
                    flavors[index] = flavor.copyWith(
                        isFavorite: !flavor.isFavorite);
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
