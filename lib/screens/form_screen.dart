import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:astro_note/models/transactions.dart';
import 'package:astro_note/provider/transaction_provider.dart';
import 'package:astro_note/main.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final contactController = TextEditingController(); // For contact information
  final descriptionController = TextEditingController(); // For description
  final fieldController = TextEditingController(); // For scientific field

  DateTime? selectedDate;
  File? selectedImage;

  // Method to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แบบฟอร์มเพิ่มข้อมูล'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display the selected date
              ListTile(
                title: Text(
                  selectedDate == null
                      ? 'เลือกวันที่'
                      : 'วันที่: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}', // Format date as 'dd/MM/yyyy'
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                controller: titleController,
                validator: (String? str) {
                  if (str!.isEmpty) {
                    return 'กรุณากรอกข้อมูล';
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: TextInputType.number,
                controller: amountController,
                validator: (String? input) {
                  try {
                    double amount = double.parse(input!);
                    if (amount < 0) {
                      return 'กรุณากรอกข้อมูลมากกว่า 0';
                    }
                  } catch (e) {
                    return 'กรุณากรอกข้อมูลเป็นตัวเลข';
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ช่องทางการติดต่อ'),
                controller: contactController,
                validator: (String? str) {
                  if (str!.isEmpty) {
                    return 'กรุณากรอกข้อมูลการติดต่อ';
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
                controller: descriptionController,
                validator: (String? str) {
                  if (str!.isEmpty) {
                    return 'กรุณากรอกข้อมูลรายละเอียด';
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ศาสตร์ที่ใช้'),
                controller: fieldController,
                validator: (String? str) {
                  if (str!.isEmpty) {
                    return 'กรุณากรอกข้อมูลศาสตร์ที่ใช้';
                  }
                },
              ),
              const SizedBox(height: 20),
              // Image picker button
              selectedImage == null
                  ? TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('อัพโหลดรูปภาพ'),
                      onPressed: _pickImage,
                    )
                  : Image.file(
                      selectedImage!,
                      height: 150,
                      width: 150,
                    ),
              TextButton(
                child: const Text('บันทึก'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Create transaction data object with selected data and image
                    var statement = Transactions(
                      keyID: null,
                      title: titleController.text,
                      amount: double.parse(amountController.text),
                      date: selectedDate ?? DateTime.now(),
                      contact: contactController.text,
                      description: descriptionController.text,
                      field: fieldController.text,
                      image: selectedImage != null ? selectedImage!.path : null,
                    );

                    var provider = Provider.of<TransactionProvider>(context, listen: false);
                    provider.addTransaction(statement);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) {
                          return MyHomePage();
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
