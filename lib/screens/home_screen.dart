import 'package:account/provider/transaction_provider.dart';
import 'package:account/screens/edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("บันทึกนัดการดูดวง"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              SystemNavigator.pop(); // ออกจากแอพ
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // ตรวจสอบว่ารายการธุรกรรมว่างหรือไม่
          if (provider.transactions.isEmpty) {
            return const Center(
              child: Text('ไม่มีรายการ'), // ไม่มีรายการธุรกรรม
            );
          } else {
            return ListView.builder(
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                var statement = provider.transactions[index];
                return Dismissible(
                  key: Key(statement.keyID
                      .toString()), 
                  direction: DismissDirection.startToEnd, // เลื่อนจากซ้ายไปขวา
                  background: Container(
                    color: Colors.red, // สีพื้นหลังเมื่อเลื่อน
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete,
                        color: Colors.white), // ไอคอนลบ
                  ),
                  confirmDismiss: (direction) async {
                    // ยืนยันการลบ
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('ยืนยันการลบ'),
                        content:
                            const Text('คุณแน่ใจหรือว่าต้องการลบรายการนี้?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('ไม่'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('ใช่'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    // ลบรายการเมื่อเลื่อนออกไป
                    provider.deleteTransaction(statement.keyID);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${statement.title} ถูกลบแล้ว')), // ข้อความฟีดแบ็ค
                    );
                  },
                  child: Card(
                    elevation: 5,
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: ListTile(
                      title: Text(statement.title), // แสดงชื่อเรื่อง
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amount: ${statement.amount}'), // แสดงจำนวนเงิน
                          Text(
                              'Date: ${DateFormat('dd MMM yyyy hh:mm:ss').format(statement.date)}'), // แสดงวันที่
                          Text(
                              'Contact: ${statement.contact}'), // แสดงข้อมูลติดต่อ
                          Text(
                              'Description: ${statement.description}'), // แสดงรายละเอียด
                          Text('Field: ${statement.field}'), // แสดงสาขา
                        ],
                      ),
                      trailing: CircleAvatar(
                        radius: 30,
                        backgroundImage: statement.image != null
                            ? FileImage(File(statement
                                .image!)) // ใช้ FileImage สำหรับไฟล์รูปภาพ
                            : null,
                        child: statement.image == null
                            ? const Icon(Icons.image,
                                size: 30) // ไอคอนจะแสดงถ้าไม่มีรูปภาพ
                            : null,
                      ),
                      onTap: () {
                        // นำทางไปยัง EditScreen เมื่อคลิกที่รายการ
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditScreen(statement: statement);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
