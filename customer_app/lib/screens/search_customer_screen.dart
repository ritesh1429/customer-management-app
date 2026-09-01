import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../widgets/customer_card.dart';
import '../widgets/alphabet_scroll_bar.dart';

class _SearchListItem {
  final bool isHeader;
  final String? letter;
  final Customer? customer;

  _SearchListItem.header(this.letter)
      : isHeader = true,
        customer = null;

  _SearchListItem.customer(this.customer)
      : isHeader = false,
        letter = null;
}

class SearchCustomerScreen extends StatefulWidget {
  const SearchCustomerScreen({super.key});

  @override
  State<SearchCustomerScreen> createState() => _SearchCustomerScreenState();
}

class _SearchCustomerScreenState extends State<SearchCustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchField = 'all'; // 'all', 'name', 'father_name'
  List<Customer> _searchResults = [];
  List<_SearchListItem> _displayItems = [];
  final Map<String, int> _letterIndices = {};
  final Set<String> _availableLetters = {};

  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter search text')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = '';
    });

    try {
      final results = await ApiService.searchCustomers(
        query,
        searchField: _searchField,
      );
      _processSearchResults(results);
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

  void _processSearchResults(List<Customer> list) {
    _searchResults = list;
    _displayItems = [];
    _letterIndices.clear();
    _availableLetters.clear();

    String? currentLetter;

    for (final customer in _searchResults) {
      final String firstChar = customer.name.isNotEmpty
          ? customer.name[0].toUpperCase()
          : '#';
      final String letter = RegExp(r'[A-Z]').hasMatch(firstChar) ? firstChar : '#';

      _availableLetters.add(letter);

      if (letter != currentLetter) {
        currentLetter = letter;
        _letterIndices[letter] = _displayItems.length;
        _displayItems.add(_SearchListItem.header(letter));
      }

      _displayItems.add(_SearchListItem.customer(customer));
    }
  }

  void _scrollToLetter(String letter) {
    if (_displayItems.isEmpty || !_scrollController.hasClients) return;

    int? targetIndex = _letterIndices[letter];

    if (targetIndex == null) {
      const allLetters = [
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
      ];
      final currentPos = allLetters.indexOf(letter);
      if (currentPos != -1) {
        for (int i = currentPos + 1; i < allLetters.length; i++) {
          if (_letterIndices.containsKey(allLetters[i])) {
            targetIndex = _letterIndices[allLetters[i]];
            break;
          }
        }
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

  String get _hintText {
    switch (_searchField) {
      case 'name':
        return 'Enter customer name (e.g. Ramesh)';
      case 'father_name':
        return "Enter father's name (e.g. Suresh)";
      default:
        return 'Search by customer or father name...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Customer'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips: All, Customer Name, Father's Name
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Fields'),
                    selected: _searchField == 'all',
                    selectedColor: Colors.indigo.shade100,
                    labelStyle: TextStyle(
                      color: _searchField == 'all' ? Colors.indigo.shade900 : Colors.black87,
                      fontWeight: _searchField == 'all' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _searchField = 'all');
                        if (_searchController.text.isNotEmpty) _performSearch();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Customer Name'),
                    selected: _searchField == 'name',
                    selectedColor: Colors.indigo.shade100,
                    labelStyle: TextStyle(
                      color: _searchField == 'name' ? Colors.indigo.shade900 : Colors.black87,
                      fontWeight: _searchField == 'name' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _searchField = 'name');
                        if (_searchController.text.isNotEmpty) _performSearch();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Father's Name"),
                    selected: _searchField == 'father_name',
                    selectedColor: Colors.indigo.shade100,
                    labelStyle: TextStyle(
                      color: _searchField == 'father_name' ? Colors.indigo.shade900 : Colors.black87,
                      fontWeight: _searchField == 'father_name' ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _searchField = 'father_name');
                        if (_searchController.text.isNotEmpty) _performSearch();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Search input bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _hintText,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults.clear();
                                  _displayItems.clear();
                                  _hasSearched = false;
                                });
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _performSearch(),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('SEARCH'),
                ),
              ],
            ),
          ),

          // Results section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      )
                    : !_hasSearched
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_search_outlined, size: 72, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  _searchField == 'father_name'
                                      ? "Search by father's name"
                                      : _searchField == 'name'
                                          ? 'Search by customer name'
                                          : 'Search by customer or father name',
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : _displayItems.isEmpty
                            ? Center(
                                child: Text(
                                  'No customers found matching "${_searchController.text}"',
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : Stack(
                                children: [
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
                                          _performSearch();
                                        },
                                      );
                                    },
                                  ),

                                  // Alphabet scroll bar
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
        ],
      ),
    );
  }
}
