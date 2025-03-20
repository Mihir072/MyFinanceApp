import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:myfinance/pages/profile_page.dart';
import 'package:myfinance/pages/transaction_page.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String userId;
  final Map<String, dynamic> userData;

  const DashboardPage({
    super.key,
    required this.username,
    required this.userId,
    required this.userData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    const String baseUrl = "https://myfinancebackend.onrender.com/auth";
    final response =
        await http.get(Uri.parse("$baseUrl/user/username/${widget.username}"));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final decodedData = jsonDecode(response.body);

        setState(() {
          userData = decodedData;
          isLoading = false;
        });
      } catch (e) {
        // ignore: avoid_print
        print("JSON Parsing Error: $e");
        setState(() {
          isLoading = false;
          userData = null;
        });
      }
    } else {
      setState(() {
        isLoading = false;
        userData = null;
      });
    }
  }

  Future<void> deleteTransaction(String txnId) async {
    const String baseUrl = "https://myfinancebackend.onrender.com";
    final String deleteUrl =
        "$baseUrl/auth/${widget.userId}/transactions/$txnId";

    try {
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction deleted successfully")),
        );

        // **Refresh user data after deletion**
        await refreshUserData();
      } else {
        // ignore: avoid_print
        print("Failed to delete: ${response.body}");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete transaction")),
        );
      }
    } catch (e) {
      print("Error deleting transaction: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong, try again")),
      );
    }
  }

  Future<void> refreshUserData() async {
    const String baseUrl = "https://myfinancebackend.onrender.com";
    final String userUrl = "$baseUrl/auth/${widget.userId}";

    try {
      final response = await http.get(Uri.parse(userUrl));

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        // ignore: avoid_print
        print("Failed to refresh user data: ${response.body}");
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error refreshing user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(username: userData?["username"] ?? ""),
                ),
              );
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchUserData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : userData == null
                ? Center(child: Text("Failed to load user data"))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Account Holder',
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          userData!["name"],
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(24)),
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TransactionPage(
                                                            username: userData![
                                                                "username"])));
                                          },
                                          child: Text(
                                            '+ Add Transaction',
                                            style: GoogleFonts.josefinSans(
                                                fontSize: 12,
                                                color: Colors.black),
                                          )),
                                    )
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Balance',
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          "₹ ${userData?["reports"]?["netBalance"] ?? 0.0}",
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Total Income',
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          "₹ ${userData?["reports"]?["totalIncome"] ?? 0.0}",
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Total Expenses',
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          "₹ ${userData?["reports"]?["totalExpenses"] ?? 0.0}",
                                          style: GoogleFonts.josefinSans(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text("Transactions",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Expanded(
                          child: userData!["transactions"] != null &&
                                  userData!["transactions"] is List &&
                                  userData!["transactions"].isNotEmpty
                              ? ListView.builder(
                                  itemCount: userData!["transactions"].length,
                                  itemBuilder: (context, index) {
                                    var transaction =
                                        userData!["transactions"][index];
                                    return Card(
                                      elevation: 3,
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: ListTile(
                                        title: Text(
                                            "Amount: ₹${transaction["amount"]}"),
                                        subtitle: Text(
                                            "Date: ${transaction["date"]}"),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              transaction["type"] == "income"
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              color: transaction["type"] ==
                                                      "income"
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                deleteTransaction(
                                                    transaction["txnId"]);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : ListView(
                                  children: [
                                    Center(
                                        child: Text("No transactions found")),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
