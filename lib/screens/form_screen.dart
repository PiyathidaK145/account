import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/models/transactions.dart';
import 'package:account/provider/transaction_provider.dart';
import 'package:account/main.dart';
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
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController contactController; 
  late TextEditingController descriptionController; 
  late TextEditingController fieldController; 

  DateTime? selectedDate;
  TimeOfDay? selectedTime; // เพิ่มตัวแปรสำหรับเวลา
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    amountController = TextEditingController();
    contactController = TextEditingController();
    descriptionController = TextEditingController();
    fieldController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    contactController.dispose();
    descriptionController.dispose();
    fieldController.dispose();
    super.dispose();
  }

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

  // Method to show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _clearForm() {
    titleController.clear();
    amountController.clear();
    contactController.clear();
    descriptionController.clear();
    fieldController.clear();
    selectedImage = null;
    selectedDate = null;
    selectedTime = null; // รีเซ็ตเวลา
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
                      : 'วันที่: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}', 
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              // Display the selected time
              ListTile(
                title: Text(
                  selectedTime == null
                      ? 'เลือกเวลา'
                      : 'เวลา: ${selectedTime!.format(context)}', // Format time
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              // Image picker button
              selectedImage == null
                  ? TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('อัพโหลดรูปภาพ'),
                      onPressed: _pickImage,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedImage!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่อหมอดู'),
                controller: titleController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูล';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ช่องทางการนัดหมาย'),
                controller: contactController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูลการติดต่อ';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ศาสตร์ที่ใช้'),
                controller: fieldController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูลศาสตร์ที่ใช้';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'โปรราคาเท่าไหร่'),
                keyboardType: TextInputType.number,
                controller: amountController,
                validator: (String? input) {
                  if (input == null || input.isEmpty) {
                    return 'กรุณากรอกข้อมูล';
                  }
                  try {
                    double amount = double.parse(input);
                    if (amount < 0) {
                      return 'กรุณากรอกข้อมูลมากกว่า 0';
                    }
                  } catch (e) {
                    return 'กรุณากรอกข้อมูลเป็นตัวเลข';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
                controller: descriptionController,
                validator: (String? str) {
                  if (str == null || str.isEmpty) {
                    return 'กรุณากรอกข้อมูลรายละเอียด';
                  }
                  return null;
                },
              ),
              TextButton(
                child: const Text('บันทึก'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // ตรวจสอบว่ามีการเลือกวันที่และเวลา
                    if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณาเลือกวันที่และเวลา')),
                      );
                      return;
                    }

                    // สร้าง DateTime ใหม่จากวันที่และเวลา
                    DateTime combinedDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    // Create transaction data object with selected data and image
                    var statement = Transactions(
                      keyID: null,
                      title: titleController.text,
                      amount: double.parse(amountController.text),
                      date: combinedDateTime, // ใช้วันที่และเวลาใหม่
                      contact: contactController.text,
                      description: descriptionController.text,
                      field: fieldController.text,
                      image: selectedImage?.path,
                    );

                    var provider = Provider.of<TransactionProvider>(context, listen: false);
                    provider.addTransaction(statement);

                    // Clear form fields after submission
                    _clearForm();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ!')),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) {
                          return const MyHomePage();
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
