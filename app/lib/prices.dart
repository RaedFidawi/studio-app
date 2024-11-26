import 'package:flutter/material.dart';
import 'prices_api.dart';

class Prices extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  Prices({required this.userInfo});

  @override
  _PricesState createState() => _PricesState();
}

class _PricesState extends State<Prices> {
  List<Map<String, dynamic>> prices = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    final String token = widget.userInfo['token'];

    try {
      List<Map<String, dynamic>> fetchedPrices = await PackagesAPI.getPackages();

      setState(() {
        prices = fetchedPrices;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load prices: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Prices",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : _buildPriceList(),
    );
  }

  Widget _buildPriceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: prices.length,
      itemBuilder: (context, index) {
        final priceData = prices[index];
        return PriceCard(
          title: priceData['name'] ?? 'No Title',
          description: priceData['description'] ?? 'No Description'
        );
      },
    );
  }
}

class PriceCard extends StatelessWidget {
  final String title;
  final String description;

  PriceCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB8860B),
            Color(0xFFFFD700),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Card(
        color: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
