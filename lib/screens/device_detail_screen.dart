import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {

  final picker = ImagePicker();
  List<File> images = [];
  int currentImage = 0;

  final cpu = TextEditingController();
  final ram = TextEditingController();
  final gpu = TextEditingController();
  final ssd = TextEditingController();
  final screen = TextEditingController();
  final description = TextEditingController();

  Future pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("Chi tiết thiết bị"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// GALLERY SWIPE
          Stack(
            children: [

              SizedBox(
                height: 220,
                child: images.isEmpty
                    ? GestureDetector(
                        onTap: pickImages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40),
                                Text("Thêm ảnh thiết bị")
                              ],
                            ),
                          ),
                        ),
                      )
                    : PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (i) {
                          setState(() {
                            currentImage = i;
                          });
                        },
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius:
                                BorderRadius.circular(20),
                            child: Image.file(
                              images[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
              ),

              /// số ảnh
              if (images.isNotEmpty)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${currentImage + 1}/${images.length}",
                      style: const TextStyle(
                          color: Colors.white),
                    ),
                  ),
                )

            ],
          ),

          const SizedBox(height: 10),

          /// thumbnail
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length + 1,
              itemBuilder: (context, index) {

                if (index == images.length) {
                  return GestureDetector(
                    onTap: pickImages,
                    child: Container(
                      width: 70,
                      margin:
                          const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentImage = index;
                    });
                  },
                  child: Container(
                    width: 70,
                    margin:
                        const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: currentImage == index
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child: Image.file(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          _title("Thông tin cấu hình"),

          _card(
            Column(
              children: [
                _row(cpu,"CPU",ram,"RAM"),
                _row(gpu,"GPU",ssd,"SSD"),
                _field(screen,"Kích thước màn hình"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// mô tả
          _title("Mô tả thiết bị"),

          _card(
            TextField(
              controller: description,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    "Nhập mô tả thiết bị...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _title("Lịch sử thiết bị"),

          _history("Công ty ABC", "01/05 - 10/05"),
          _history("Bảo trì RAM", "20/05"),
          _history("Công ty XYZ", "01/06 - 15/06"),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Cập nhật"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {},
                  child:
                      const Text("Ngừng kinh doanh"),
                ),
              ),

            ],
          )

        ],
      ),
    );
  }

  Widget _title(text){
    return Padding(
      padding: const EdgeInsets.only(bottom:10),
      child: Text(text,
          style: const TextStyle(
              fontSize:18,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _card(child){
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _row(c1,t1,c2,t2){
    return Row(
      children: [
        Expanded(child: _field(c1,t1)),
        const SizedBox(width:10),
        Expanded(child: _field(c2,t2)),
      ],
    );
  }

  Widget _field(controller,text){
    return Padding(
      padding: const EdgeInsets.only(bottom:10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: text,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _history(title,date){
    return Card(
      child: ListTile(
        leading:
            const Icon(Icons.history),
        title: Text(title),
        subtitle: Text(date),
      ),
    );
  }
}