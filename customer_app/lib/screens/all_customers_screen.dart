import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../widgets/customer_card.dart';
import '../widgets/alphabet_scroll_bar.dart';

class _ListItem {
  final bool isHeader;
  final String? letter;
  final Customer? customer;

  _ListItem.header(this.letter)
      : isHeader = true,
        customer = null;

  _ListItem.customer(this.customer)
      : isHeader = false,
        letter = null;
}

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Customer> _customers = [];
  List<_ListItem> _displayItems = [];
  final Map<String, int> _letterIndices = {};
  final Set<String> _availableLetters = {};

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final list = await ApiService.fetchAllCustomers(skip: 0, limit: 200);
      _processCustomerList(list);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processCustomerList(List<Customer> list) {
    _customers = list;
    _displayItems = [];
    _letterIndices.clear();
    _availableLetters.clear();

    String? currentLetter;

    for (final customer in _customers) {
      final String firstChar = customer.name.isNotEmpty
          ? customer.name[0].toUpperCase()
          : '#';
      final String letter = RegExp(r'[A-Z]').hasMatch(firstChar) ? firstChar : '#';

      _availableLetters.add(letter);

      if (letter != currentLetter) {
        currentLetter = letter;
        _letterIndices[letter] = _displayItems.length;
        _displayItems.add(_ListItem.header(letter));
      }

      _displayItems.add(_ListItem.customer(customer));
    }
  }

  void _scrollToLetter(String letter) {
    if (_displayItems.isEmpty || !_scrollController.hasClients) return;

    int? targetIndex = _letterIndices[letter];

    // If exact letter not found, find closest subsequent letter or previous letter
    if (targetIndex == null) {
      const allLetters = [
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
      ];
      final currentPos = allLetters.indexOf(letter);
      if (currentPos != -1) {
        // Look ahead
        for (int i = currentPos + 1; i < allLetters.length; i++) {
          if (_letterIndices.containsKey(allLetters[i])) {
            targetIndex = _letterIndices[allLetters[i]];
            break;
          }
        }
        // Look behind if still null
        if (targetIndex == null) {
          for (int i = currentPos - 1; i >= 0; i--) {
            if (_letterIndices.containsKey(allLetters[i])) {
              targetIndex = _letterIndices[allLetters[i]];
              break;
            }
          }
        }
      }
    }

    if (targetIndex != null) {
      double targetOffset = 0.0;
      for (int i = 0; i < targetIndex; i++) {
        targetOffset += _displayItems[i].isHeader ? 38.0 : 138.0;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(targetOffset.clamp(0.0, maxScroll));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customers'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCustomers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadCustomers,
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  )
                : _displayItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_outlined, size: 72, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No customers found in database',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          // Main Customer List with right padding for alphabet bar
                          ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 30),
                            itemCount: _displayItems.length,
                            itemBuilder: (context, index) {
                              final item = _displayItems[index];

                              if (item.isHeader) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 12, bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item.letter!,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo.shade900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.indigo.shade100,
                                          thickness: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final customer = item.customer!;
                              return CustomerCard(
                                customer: customer,
                                onDeleteSuccess: () {
                                  _loadCustomers();
                                },
                              );
                            },
                          ),

                          // Right-Side Alphabetical Scroll Bar
                          Positioned(
                            top: 8,
                            bottom: 8,
                            right: 0,
                            child: AlphabetScrollBar(
                              availableLetters: _availableLetters.toList(),
                              onLetterSelected: _scrollToLetter,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
