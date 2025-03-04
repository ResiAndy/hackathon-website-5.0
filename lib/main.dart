import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// A simple global user data store (for this demo).
class GlobalUserData {
  static String userName = "John Doe";
  static String userEmail = "john@sample.com";
  static double userBalance = 120.75;
  static List<String> recentPurchases = [];
}

// ==============================================
// main()
// ==============================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ==============================================
// MyApp
// ==============================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clotify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
      routes: {
        '/gallery': (context) => const KeyboardZoomWrapper(),
        '/about': (context) => const AboutUsScreen(),
        '/team': (context) => const TeamScreen(),
      },
    );
  }
}

// ==============================================
// DASHBOARD SCREEN
// ==============================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _backgroundImage = '';

  @override
  void initState() {
    super.initState();
    _loadBackground();
  }

  void _loadBackground() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Default image if not found in prefs
      _backgroundImage = prefs.getString('bg')
          ?? 'https://i.postimg.cc/bvC6LjRH/Clotify.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Default multipliers for large screens
    double widthMultiplier = 3.0;
    double heightMultiplier = 1.3;
    double xOffset = -150.0;

    // Adjust for very small screens
    if (screenWidth < 400) {
      widthMultiplier = 1.2;
      heightMultiplier = 1.0;
      xOffset = -50;
    }
    // Adjust for mid-sized screens
    else if (screenWidth < 800) {
      widthMultiplier = 2.0;
      heightMultiplier = 1.1;
      xOffset = -100;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clotify Main Menu'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Clotify Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Clothing Catalogue'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const KeyboardZoomWrapper()),
              ),
            ),
            ListTile(
              title: const Text('About Us'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              ),
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            // Background image, centered & dynamically sized
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(xOffset, 0), // Adapted based on screen width
                child: Container(
                  width: screenWidth * widthMultiplier,
                  height: screenHeight * heightMultiplier,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_backgroundImage),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // "Enter the app" button
            Positioned(
              right: 30,
              bottom: screenHeight * 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Welcome to Clotify!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const KeyboardZoomWrapper()),
                    ),
                    child: const Text('Enter the app'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================
// ABOUT US SCREEN
// ==============================================
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Clotify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeamScreen()),
            ),
          ),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 1.2,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Image.network(
              'https://i.postimg.cc/kXJqkJyx/Add-a-Call-to-Action.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================
// TEAM SCREEN
// ==============================================
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Team')),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 1.2,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Image.network(
            'https://i.postimg.cc/X7Y6s2VL/Maic-l-S1-Graphic-Design-Leader.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ==============================================
// KeyboardZoomWrapper - captures Ctrl+Shift+(+/-) to scale entire UI
// ==============================================
class KeyboardZoomWrapper extends StatefulWidget {
  const KeyboardZoomWrapper({Key? key}) : super(key: key);

  @override
  State<KeyboardZoomWrapper> createState() => _KeyboardZoomWrapperState();
}

class _KeyboardZoomWrapperState extends State<KeyboardZoomWrapper> {
  final FocusNode _focusNode = FocusNode();
  double _scale = 1.0;
  bool _ctrlDown = false;
  bool _shiftDown = false;

  void _handleKeyEvent(RawKeyEvent event) {
    final isKeyDown = event is RawKeyDownEvent;
    setState(() {
      _ctrlDown = event.isControlPressed;
      _shiftDown = event.isShiftPressed;
    });
    if (isKeyDown && _ctrlDown && _shiftDown) {
      if (event.logicalKey == LogicalKeyboardKey.equal) {
        _zoomIn();
      } else if (event.logicalKey == LogicalKeyboardKey.minus) {
        _zoomOut();
      }
    }
  }

  void _zoomIn() {
    setState(() {
      _scale += 0.1;
      _scale = _scale.clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale -= 0.1;
      _scale = _scale.clamp(0.5, 3.0);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Transform.scale(
        scale: _scale,
        alignment: Alignment.topLeft,
        child: const ClothingGallery(),
      ),
    );
  }
}

// ==============================================
// ClothingGallery
// ==============================================
class ClothingGallery extends StatefulWidget {
  const ClothingGallery({super.key});

  @override
  State<ClothingGallery> createState() => _ClothingGalleryState();
}

class _ClothingGalleryState extends State<ClothingGallery> {
  String _backgroundImage = '';
  final TextEditingController _bgController = TextEditingController();

  final List<Map<String, dynamic>> allClothingItems = [
    {
      'name': 'T-shirt',
      'price': 20.0,
      'category': 'Men',
      'image': 'https://i.postimg.cc/59K3kwGr/image.webp',
      'type': 'torso',
    },
    {
      'name': 'Jeans',
      'price': 40.0,
      'category': 'Men',
      'image': 'https://i.postimg.cc/2ygnjxN8/image-1.webp',
      'type': 'legs',
    },
    {
      'name': 'Jacket',
      'price': 60.0,
      'category': 'Women',
      'image': 'https://i.postimg.cc/85RCfBvz/image-2.webp',
      'type': 'torso',
    },
    {
      'name': 'Sneakers',
      'price': 50.0,
      'category': 'Unisex',
      'image': 'https://i.postimg.cc/C1sFxMyZ/image-3.webp',
      'type': 'feet',
    },
    {
      'name': 'Hat',
      'price': 30.0,
      'category': 'Unisex',
      'image': 'https://i.postimg.cc/rFPqmYH9/image-4.webp',
      'type': 'head',
    },
    {
      'name': 'Dress',
      'price': 70.0,
      'category': 'Women',
      'image': 'https://i.postimg.cc/MKv8hmGf/image-5.webp',
      'type': 'torso',
    },
    {
      'name': 'Skirt',
      'price': 35.0,
      'category': 'Women',
      'image': 'https://i.postimg.cc/cJcjKvHN/image-6.webp',
      'type': 'legs',
    },
    {
      'name': 'Hoodie',
      'price': 45.0,
      'category': 'Unisex',
      'image': 'https://i.postimg.cc/VkFQtGGT/image-7.webp',
      'type': 'torso',
    },
    {
      'name': 'Shorts',
      'price': 25.0,
      'category': 'Men',
      'image': 'https://i.postimg.cc/15cY7gGV/image-8.webp',
      'type': 'legs',
    },
    {
      'name': 'Sweater',
      'price': 50.0,
      'category': 'Women',
      'image': 'https://i.postimg.cc/5yJS83k7/image-9.webp',
      'type': 'torso',
    },
  ];

  final List<Map<String, dynamic>> cart = [];
  String searchQuery = '';
  final List<String> categories = ['All', 'Men', 'Women', 'Unisex'];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadBackground();
  }

  void _loadBackground() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _backgroundImage = prefs.getString('catalogue_bg') ??
          'https://i.postimg.cc/Y0Tm0vRy/background.png'; // Default
    });
  }

  void _saveBackground(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('catalogue_bg', url);
    setState(() => _backgroundImage = url);
  }

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

  int _levenshteinDistance(String s, String t) {
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final dist = List.generate(
      s.length + 1,
      (_) => List.filled(t.length + 1, 0),
    );
    for (int i = 0; i <= s.length; i++) dist[i][0] = i;
    for (int j = 0; j <= t.length; j++) dist[0][j] = j;
    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = (s[i - 1] == t[j - 1]) ? 0 : 1;
        dist[i][j] = [
          dist[i - 1][j] + 1,
          dist[i][j - 1] + 1,
          dist[i - 1][j - 1] + cost
        ].reduce(min);
      }
    }
    return dist[s.length][t.length];
  }

  List<Map<String, dynamic>> get filteredItems {
    final normQuery = _normalize(searchQuery);
    if (normQuery.isEmpty) {
      return _categoryFilter(allClothingItems);
    }
    final direct = allClothingItems.where((item) {
      final normName = _normalize(item['name']);
      return normName.contains(normQuery);
    }).toList();
    if (direct.isNotEmpty) {
      return _categoryFilter(direct);
    }
    final fuzzy = allClothingItems.where((item) {
      final normName = _normalize(item['name']);
      return _levenshteinDistance(normName, normQuery) <= 2;
    }).toList();
    return _categoryFilter(fuzzy);
  }

  List<Map<String, dynamic>> _categoryFilter(List<Map<String, dynamic>> items) {
    if (selectedCategory == 'All') return items;
    return items.where((x) => x['category'] == selectedCategory).toList();
  }

  void addToCart(Map<String, dynamic> item) {
    final idx =
        cart.indexWhere((element) => element['item']['name'] == item['name']);
    setState(() {
      if (idx == -1) {
        cart.add({
          'item': item,
          'quantity': 1,
          'originalPrice': item['price'],
        });
      } else {
        cart[idx]['quantity'] += 1;
      }
    });
  }

  void showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (ctx, scrollController) {
            return CartWidget(
              cart: cart,
              scrollController: scrollController,
              onCartUpdated: () => setState(() {}),
            );
          },
        );
      },
    );
  }

  void showNegotiationChat(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NegotiationChatScreen(
          item: item,
          onPriceChanged: (newPrice) {
            setState(() {
              item['price'] = newPrice;
            });
          },
        ),
      ),
    );
  }

  void showZoomScreen(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageZoomScreen(imageUrl: imageUrl)),
    );
  }

  void showCustomizeScreen(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomizeScreen(
          item: item,
          onItemUpdated: (_) => setState(() {}),
        ),
      ),
    );
  }

  void showVirtualFittingRoom() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items in cart to try on.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UniversalFittingScreen(cartItems: cart)),
    );
  }

  void showUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void returnToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Catalogue background
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(_backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // AppBar-like row at the top
            AppBar(
              title: SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (val) => setState(() {
                    searchQuery = val;
                  }),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Set Catalogue Background'),
                      content: TextField(
                        controller: _bgController,
                        decoration: const InputDecoration(
                          hintText: 'Paste image URL',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_bgController.text.isNotEmpty) {
                              _saveBackground(_bgController.text);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: showUserProfile,
                ),
                IconButton(
                  icon: const Icon(Icons.style),
                  onPressed: showVirtualFittingRoom,
                ),
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (cart.isNotEmpty)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: showCart,
                ),
              ],
            ),

            // Category filter row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Main grid of items
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // *** DYNAMIC CROSS-AXIS-COUNT LOGIC ***
                  // For example, base it on a minimum tile width of ~200
                  const double spacing = 10.0;
                  const double minItemWidth = 200.0;
                  int crossAxisCount =
                      (constraints.maxWidth ~/ minItemWidth).clamp(1, 6);

                  // You can tweak the factor below to adjust item height
                  // or use a ratio that suits your design.
                  final totalSpacing = (crossAxisCount - 1) * spacing;
                  final itemWidth =
                      (constraints.maxWidth - totalSpacing) / crossAxisCount;
                  final itemHeight = 320.0; // or itemWidth * someAspectRatio

                  return GridView.builder(
                    padding: const EdgeInsets.all(spacing),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing * 2,
                      childAspectRatio: itemWidth / itemHeight,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (ctx, index) {
                      final item = filteredItems[index];
                      return Card(
                        elevation: 4,
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      item['image'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image, size: 10),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(4),
                                        minimumSize: const Size(0, 0),
                                      ),
                                      onPressed: () =>
                                          showZoomScreen(item['image']),
                                      child: const Text(
                                        'Zoom',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${item['price']}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        'Category: ${item['category']}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => addToCart(item),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size(80, 30),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                            ),
                                            child: const Text('Add'),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                showCustomizeScreen(item),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size(80, 30),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                            ),
                                            child: const Text('Customize'),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                showNegotiationChat(item),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size(80, 30),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                            ),
                                            child: const Text('Negotiate'),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: showVirtualFittingRoom,
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size(80, 30),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                            ),
                                            child: const Text('Try On'),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Clotify Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Main Menu'),
              onTap: () => returnToDashboard(),
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                showUserProfile();
              },
            ),
            ListTile(
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================
// UniversalFittingScreen - multiple items at once
// ==============================================
class UniversalFittingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const UniversalFittingScreen({Key? key, required this.cartItems})
      : super(key: key);

  @override
  State<UniversalFittingScreen> createState() => _UniversalFittingScreenState();
}

class _UniversalFittingScreenState extends State<UniversalFittingScreen> {
  final List<_FittingItem> items = [];
  final double snapThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    // Initialize items based on cartItems
    for (int i = 0; i < widget.cartItems.length; i++) {
      final cartItem = widget.cartItems[i];
      final clothingItem = cartItem['item'];
      items.add(
        _FittingItem(
          imageUrl: clothingItem['image'],
          name: clothingItem['name'],
          type: clothingItem['type'],
          x: 50.0 + i * 120,
          y: 200.0,
          scale: 1.0,
        ),
      );
    }
  }

  Map<String, Offset> _getAnchorPoints(Size screenSize) {
    return {
      'torso': Offset(screenSize.width * 0.5, screenSize.height * 0.3),
      'legs': Offset(screenSize.width * 0.5, screenSize.height * 0.5),
      'feet': Offset(screenSize.width * 0.5, screenSize.height * 0.75),
      'head': Offset(screenSize.width * 0.5, screenSize.height * 0.1),
    };
  }

  void _updateItem(_FittingItem updated, int index, Size screenSize) {
    final anchorPoints = _getAnchorPoints(screenSize);
    bool snapped = false;

    final double imageWidth = 120 * updated.scale;
    final double imageHeight = 120 * updated.scale;

    final targetAnchor = anchorPoints[updated.type];
    if (targetAnchor != null) {
      final double centerX = updated.x + imageWidth / 2;
      final double centerY = updated.y + imageHeight / 2;
      final double dx = centerX - targetAnchor.dx;
      final double dy = centerY - targetAnchor.dy;
      final double distance = sqrt(dx * dx + dy * dy);

      if (distance < snapThreshold) {
        final snappedX = targetAnchor.dx - imageWidth / 2;
        final snappedY = targetAnchor.dy - imageHeight / 2;
        updated = updated.copyWith(
          x: snappedX,
          y: snappedY,
          isSnapped: true,
        );
        snapped = true;
      }
    }

    if (!snapped) {
      updated = updated.copyWith(isSnapped: false);
    }

    setState(() => items[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Try-On: Multiple Combinations'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://i.postimg.cc/4dhfCdV4/DALL-E-2025-02-16-10-53-37-A-simple-2-D-full-body-mannequin-designed-for-a-virtual-fitting-room-Th.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          for (int i = 0; i < items.length; i++)
            _DraggableFittingItem(
              item: items[i],
              parentWidth: screenSize.width,
              parentHeight: screenSize.height,
              onChanged: (updated) => _updateItem(updated, i, screenSize),
            ),
        ],
      ),
    );
  }
}

class _FittingItem {
  final String imageUrl;
  final String name;
  final String type;
  final double x;
  final double y;
  final double scale;
  final bool isSnapped;

  const _FittingItem({
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.scale,
    this.isSnapped = false,
  });

  _FittingItem copyWith({
    String? imageUrl,
    String? name,
    String? type,
    double? x,
    double? y,
    double? scale,
    bool? isSnapped,
  }) {
    return _FittingItem(
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      isSnapped: isSnapped ?? this.isSnapped,
    );
  }
}

// ==============================================
// _DraggableFittingItem
// ==============================================
class _DraggableFittingItem extends StatefulWidget {
  final _FittingItem item;
  final double parentWidth;
  final double parentHeight;
  final ValueChanged<_FittingItem> onChanged;

  const _DraggableFittingItem({
    Key? key,
    required this.item,
    required this.parentWidth,
    required this.parentHeight,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_DraggableFittingItem> createState() => _DraggableFittingItemState();
}

class _DraggableFittingItemState extends State<_DraggableFittingItem> {
  late double _left;
  late double _top;
  late double _scale;

  @override
  void initState() {
    super.initState();
    _left = widget.item.x;
    _top = widget.item.y;
    _scale = widget.item.scale;
  }

  @override
  void didUpdateWidget(covariant _DraggableFittingItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.x != oldWidget.item.x ||
        widget.item.y != oldWidget.item.y ||
        widget.item.scale != oldWidget.item.scale) {
      setState(() {
        _left = widget.item.x;
        _top = widget.item.y;
        _scale = widget.item.scale;
      });
    }
  }

  void _scaleUp() {
    setState(() => _scale += 0.1);
    _updateParent();
  }

  void _scaleDown() {
    setState(() => _scale = (_scale - 0.1).clamp(0.5, 3.0));
    _updateParent();
  }

  void _updateParent() {
    widget.onChanged(widget.item.copyWith(
      x: _left,
      y: _top,
      scale: _scale,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = 120 * _scale;

    return Positioned(
      left: _left,
      top: _top,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _left += details.delta.dx;
            _top += details.delta.dy;
          });
          _updateParent();
        },
        onPanEnd: (_) => _updateParent(),
        child: Container(
          width: imageSize,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.item.isSnapped ? Colors.green : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                widget.item.imageUrl,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  width: imageSize,
                  height: imageSize,
                  child: const Icon(Icons.image, size: 50),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: _scaleUp,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: _scaleDown,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================
// CustomizeScreen
// ==============================================
class CustomizeScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final ValueChanged<Map<String, dynamic>> onItemUpdated;

  const CustomizeScreen({
    Key? key,
    required this.item,
    required this.onItemUpdated,
  }) : super(key: key);

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  List<String> get _appropriateSizes {
    final itemName = widget.item['name'].toString().toLowerCase();
    if (itemName.contains('shoe') || itemName.contains('sneaker')) {
      return ['7', '8', '9', '10', '11', '12'];
    }
    return ['S', 'M', 'L', 'XL'];
  }

  String? selectedSize;
  final TextEditingController designPromptController = TextEditingController();
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.item['size'] as String?;
    designPromptController.text = (widget.item['designPrompt'] ?? '') as String;
  }

  Future<void> generateAIImage() async {
    final userPrompt = designPromptController.text.trim();
    if (userPrompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a design prompt first.')),
      );
      return;
    }

    setState(() => isGenerating = true);

    try {
      final String itemType = widget.item['name'];
      final String finalPrompt =
          "A stylish, high-quality, no text, white background, one full piece of $itemType featuring: $userPrompt";

      final generateImageUrl =
          Uri.parse('https://generateimage-pv7pi7zqtq-uc.a.run.app');

      final resp = await http.post(
        generateImageUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': "dall-e-3",
          'prompt': finalPrompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final newUrl = data['data'][0]['url'];
        if (kDebugMode) {
          print('Base AI image URL: $newUrl');
        }

        // If your backend requires a proxy, you can wrap the newUrl:
        final proxyUrl =
            'https://proxyimage-pv7pi7zqtq-uc.a.run.app?url=${Uri.encodeComponent(newUrl)}';

        setState(() {
          widget.item['image'] = proxyUrl;
        });
      } else {
        if (kDebugMode) {
          print('Backend generation error: ${resp.body}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gen error: ${resp.statusCode} - ${resp.body}'),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in generateAIImage: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating image: $e')),
      );
    } finally {
      setState(() => isGenerating = false);
    }
  }

  void applyCustomization() {
    widget.item['size'] = selectedSize;
    widget.item['designPrompt'] = designPromptController.text.trim();
    widget.onItemUpdated(widget.item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = widget.item['image'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Customize ${widget.item['name']}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                currentImage,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey.shade200,
                  width: 200,
                  height: 200,
                  child: const Icon(Icons.image, size: 50),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Select Size:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedSize,
                  hint: const Text('Choose Size'),
                  items: _appropriateSizes.map((sz) {
                    return DropdownMenuItem<String>(
                      value: sz,
                      child: Text(sz),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedSize = val);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: designPromptController,
              decoration: const InputDecoration(
                labelText: 'Design Prompt',
                hintText: 'e.g. "Floral pattern", "Dragon logo"',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: isGenerating ? null : generateAIImage,
                child: isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate AI Image'),
              ),
              ElevatedButton(
                onPressed: applyCustomization,
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ==============================================
// Cart Widget - includes a "Checkout" button
// ==============================================
class CartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final ScrollController scrollController;
  final VoidCallback onCartUpdated;

  const CartWidget({
    Key? key,
    required this.cart,
    required this.scrollController,
    required this.onCartUpdated,
  }) : super(key: key);

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  void _increaseQuantity(int i) {
    setState(() {
      widget.cart[i]['quantity'] += 1;
    });
    widget.onCartUpdated();
  }

  void _decreaseQuantity(int i) {
    setState(() {
      widget.cart[i]['quantity'] -= 1;
      if (widget.cart[i]['quantity'] <= 0) {
        widget.cart.removeAt(i);
      }
    });
    widget.onCartUpdated();
  }

  void _checkout() {
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your cart is empty, cannot checkout.'),
      ));
      return;
    }

    double total = 0;
    final itemsPurchased = <String>[];
    for (var c in widget.cart) {
      final item = c['item'];
      final qty = c['quantity'] as int;
      final linePrice = (item['price'] as double) * qty;
      total += linePrice;
      itemsPurchased.add("${item['name']} x$qty - \$${linePrice.toStringAsFixed(2)}");
    }

    if (GlobalUserData.userBalance < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Insufficient balance (need \$${total.toStringAsFixed(2)}).'),
        ),
      );
      return;
    }

    setState(() {
      GlobalUserData.userBalance -= total;
    });

    // Record the purchases
    for (final purchased in itemsPurchased.reversed) {
      GlobalUserData.recentPurchases.insert(0, purchased);
    }

    widget.cart.clear();
    widget.onCartUpdated();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Purchased successfully! - \$${total.toStringAsFixed(2)} spent.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var c in widget.cart) {
      final price = c['item']['price'] as double;
      final qty = c['quantity'] as int;
      total += price * qty;
    }

    return Column(
      children: [
        Container(
          height: 5,
          width: 50,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        const Text(
          'Your Cart',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: widget.cart.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : ListView.builder(
                  controller: widget.scrollController,
                  itemCount: widget.cart.length,
                  itemBuilder: (ctx, i) {
                    final cartItem = widget.cart[i];
                    final item = cartItem['item'];
                    final qty = cartItem['quantity'] as int;
                    final linePrice = (item['price'] as double) * qty;
                    return ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(
                          item['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 25),
                          ),
                        ),
                      ),
                      title: Text(item['name']),
                      subtitle: Text('\$${linePrice.toStringAsFixed(2)}'),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _decreaseQuantity(i),
                            ),
                            Text('$qty'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _increaseQuantity(i),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: _checkout,
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==============================================
// NegotiationChatScreen
// ==============================================
class NegotiationChatScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final ValueChanged<double> onPriceChanged;

  const NegotiationChatScreen({
    Key? key,
    required this.item,
    required this.onPriceChanged,
  }) : super(key: key);

  @override
  State<NegotiationChatScreen> createState() => _NegotiationChatScreenState();
}

class _NegotiationChatScreenState extends State<NegotiationChatScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  late double currentPrice;     // The current negotiation price
  late double finalPrice;       // The final "agreed" price in case it changes
  late double originalPrice;    // The never-changing original price
  late double floorPrice;       // The minimum we’ll ever allow

  @override
  void initState() {
    super.initState();

    // 1) Check if we already stored an original price in the item data.
    //    If not, store item['price'] as originalPrice so it never changes.
    if (widget.item['originalPrice'] == null) {
      widget.item['originalPrice'] = widget.item['price'];
    }

    // 2) The originalPrice we use for all negotiations:
    originalPrice = widget.item['originalPrice'];

    // 3) If the item was already discounted previously, we start at that "current" price,
    //    but we never let them push it below 'floorPrice' from the original.
    currentPrice = widget.item['price'];
    // Or if you want to start fresh each time, do:
    // currentPrice = originalPrice;

    // 4) Compute your floor price from the original. For example 90%.
    floorPrice = originalPrice * 0.9;

    // Initialize our chat
    messages.add({
      'sender': 'AI',
      'text': 'Hello! Let\'s negotiate the price for ${widget.item['name']}.'
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({'sender': 'You', 'text': text});
      _processNegotiation(text);
    });
    _controller.clear();
  }

  void _processNegotiation(String userText) {
    // Grab the first integer you find in the user text
    final match = RegExp(r'([0-9]+)').firstMatch(userText);

    if (match != null) {
      final proposed = double.tryParse(match.group(1)!);
      if (proposed == null) {
        _reply("I couldn't parse the price you typed.");
        return;
      }

      // If the user tries to propose >= current price, no change
      if (proposed >= currentPrice) {
        _reply('Your offer is >= the current price!');
        return;
      }

      // If our current price is already at or below floor, don't go lower.
      if (currentPrice <= floorPrice) {
        _reply('We\'ve already hit the lowest I can go: '
               '\$${floorPrice.toStringAsFixed(2)}.');
        return;
      }

      // If the user’s proposed price is still below the floor,
      // we simply say "can’t go below floorPrice."
      if (proposed < floorPrice) {
        _reply('I can\'t go below \$${floorPrice.toStringAsFixed(2)}.');
        return;
      }

      // Otherwise, the user's proposed price is between floorPrice and currentPrice.
      // We randomly decide how to respond:
      final rnd = Random().nextInt(100);
      if (rnd < 33) {
        // Accept the user's offer
        currentPrice = proposed;
        _updatePrice(currentPrice);
        _reply('Deal! Price is now \$${currentPrice.toStringAsFixed(2)}.');
      } else if (rnd < 66) {
        // Counter-offer halfway between currentPrice and proposed
        final diff = currentPrice - proposed;
        double newP = currentPrice - diff / 2;

        // If halfway is still below the floor, clamp to floorPrice
        if (newP < floorPrice) {
          newP = floorPrice;
          _reply('Actually, I can\'t go below \$${floorPrice.toStringAsFixed(2)}.');
        } else {
          _reply('How about \$${newP.toStringAsFixed(2)} instead?');
        }

        currentPrice = newP;
        _updatePrice(currentPrice);
      } else {
        // Otherwise, we say "nope" and keep the current price
        _reply('Nope, best I can do is \$${currentPrice.toStringAsFixed(2)}.');
      }
    } else {
      // The user typed no numeric offer
      final rand = Random().nextInt(3);
      switch (rand) {
        case 0:
          _reply('Please give me a numeric price.');
          break;
        case 1:
          _reply('Could you specify a number for the price?');
          break;
        default:
          _reply('Not sure, can you type a numeric offer?');
      }
    }
  }

  /// Helper that updates the item price in parent (and in our local map)
  void _updatePrice(double newPrice) {
    // Actually update the item in your parent data so the "discount" persists
    widget.item['price'] = newPrice;
    // Inform the parent widget, if needed
    widget.onPriceChanged(newPrice);
  }

  void _reply(String text) {
    setState(() {
      messages.add({'sender': 'AI', 'text': text});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Negotiation for ${widget.item['name']}'),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                final isUser = msg['sender'] == 'You';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${msg['sender']}: ${msg['text']}',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Text Field + Send Button
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Propose a price...'),
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================
// ImageZoomScreen
// ==============================================
class ImageZoomScreen extends StatefulWidget {
  final String imageUrl;
  const ImageZoomScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<ImageZoomScreen> createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  double _scale = 1.0;

  void _zoomIn() {
    setState(() {
      _scale += 0.25;
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale - 0.25).clamp(0.5, 5.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoom View'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Transform.scale(
                  scale: _scale,
                  child: Image.network(
                    widget.imageUrl,
                    errorBuilder: (ctx, e, stack) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _zoomOut,
                  child: const Text('−', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: _zoomIn,
                  child: const Text('+', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================
// ProfileScreen - more responsive layout
// ==============================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPurchaseController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = GlobalUserData.userName;
    emailController.text = GlobalUserData.userEmail;
    _balanceController.text =
        GlobalUserData.userBalance.toStringAsFixed(2);
  }

  void _updateBalance() {
    final newVal = double.tryParse(_balanceController.text.trim());
    if (newVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number.')),
      );
      return;
    }
    setState(() {
      GlobalUserData.userBalance = newVal;
    });
  }

  void toggleEdit() {
    setState(() {
      if (!isEditing) {
        isEditing = true;
      } else {
        isEditing = false;
        GlobalUserData.userName = nameController.text.trim();
        GlobalUserData.userEmail = emailController.text.trim();
      }
    });
  }

  void addFunds(double amount) {
    setState(() {
      GlobalUserData.userBalance += amount;
    });
  }

  void addPurchase() {
    final purchaseText = newPurchaseController.text.trim();
    if (purchaseText.isEmpty) return;
    setState(() {
      GlobalUserData.recentPurchases.insert(0, purchaseText);
      newPurchaseController.clear();
    });
  }

  void removePurchase(int index) {
    setState(() {
      GlobalUserData.recentPurchases.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // We'll wrap the "profile header" in a LayoutBuilder or simply check screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 500;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            // If narrow, stack vertically, else horizontally
            isNarrow
                ? Column(
                    children: _buildProfileHeaderWidgets(),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNameEmailEditor(),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),

            // Balance editing
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance: \$${GlobalUserData.userBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _balanceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter new balance amount',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _updateBalance,
                        child: const Text('Set Balance'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Purchases:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: newPurchaseController,
                    decoration: const InputDecoration(
                      hintText: 'Enter new purchase (e.g. "Hat - \$15")',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addPurchase,
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Expanded(
              child: GlobalUserData.recentPurchases.isEmpty
                  ? const Center(child: Text('No purchases yet.'))
                  : ListView.builder(
                      itemCount: GlobalUserData.recentPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = GlobalUserData.recentPurchases[index];
                        return ListTile(
                          leading: const Icon(Icons.shopping_bag),
                          title: Text(purchase),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removePurchase(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade200,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 40),
    );
  }

  Widget _buildNameEmailEditor() {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            GlobalUserData.userName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            GlobalUserData.userEmail,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      );
    }
  }

  // For narrow screens, we can stack the avatar and name/email
  List<Widget> _buildProfileHeaderWidgets() {
    return [
      _buildAvatar(),
      const SizedBox(height: 16),
      _buildNameEmailEditor(),
    ];
  }
}
