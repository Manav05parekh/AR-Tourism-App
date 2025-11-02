import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../services/voice_service.dart';
import '../services/yolo_service.dart';
import '../main.dart';
import 'dart:math';
import 'maps.dart';

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  CameraController? _cameraController;
  bool _isReady = false;
  bool _isListening = false;
  String _conversation = "";
  double _speechRate = 1.0;
  bool _isDetailed = false;
  bool _showChatBox = false;

  final VoiceService _voiceService = VoiceService();
  final YoloService _yoloService = YoloService();

  // 🔹 Unified FAQ data (you can add more sections here)
  final Map<String, Map<String, String>> _faq = {
    "DJ_Sanghvi": {
  "what is dj sanghvi college":
      "Dwarkadas J. Sanghvi College of Engineering (DJSCE) is one of Mumbai’s top engineering colleges, affiliated with the University of Mumbai and managed by the SVKM Trust.",

  "dj sanghvi kya hai":
      "DJ Sanghvi ek top engineering college hai Mumbai mein, jo SVKM Trust ke under aata hai aur University of Mumbai se affiliated hai.",

  "where is dj sanghvi located":
      "D. J. Sanghvi College of Engineering is located in Vile Parle West, Mumbai, Maharashtra.",

  "dj sanghvi kahaan hai":
      "DJ Sanghvi Vile Parle West, Mumbai mein hai — SVKM campus ke andar.",

  "when was dj sanghvi established":
      "DJSCE was established in 1994 by the Shri Vile Parle Kelavani Mandal (SVKM) Trust.",

  "dj sanghvi kab bana tha":
      "DJ Sanghvi College 1994 mein establish hua tha, SVKM Trust ke dwara.",

  "who founded dj sanghvi college":
      "The college was founded by the SVKM Trust, which also manages reputed institutions like NMIMS University and Mithibai College.",

  "dj sanghvi kisne banaya":
      "Is college ko SVKM Trust ne banaya hai, jo NMIMS aur Mithibai jaise institutes bhi chalata hai.",

  "is dj sanghvi affiliated to mumbai university":
      "Yes, DJSCE is affiliated with the University of Mumbai and its degree programs are approved by AICTE.",

  "dj sanghvi mumbai university se affiliated hai kya":
      "Haan, DJ Sanghvi University of Mumbai se affiliated hai aur AICTE approved bhi hai.",

  "is dj sanghvi a private or government college":
      "DJ Sanghvi College is a private, self-financed institution managed by the SVKM Trust.",

  "dj sanghvi private hai kya":
      "Haan, DJ Sanghvi ek private college hai, jo SVKM Trust ke under aata hai.",

  "does dj sanghvi offer scholarships":
      "Yes, the college offers merit-based scholarships through the SVKM Trust and government schemes like EBC, SC/ST, and minority scholarships.",

  "dj sanghvi me scholarship milti hai kya":
      "Haan, yahan merit-based aur government schemes jaise EBC, SC/ST, minority scholarships milti hain.",

  "does dj sanghvi have nirf ranking":
      "DJSCE has been consistently ranked among the top private engineering colleges in Maharashtra and appears in the NIRF band for engineering institutions.",

  "dj sanghvi ki nirf ranking kya hai":
      "DJ Sanghvi Maharashtra ke top private engineering colleges mein ranked hai aur NIRF band mein bhi aata hai.",

  "is dj sanghvi autonomous":
      "Yes, DJSCE was granted autonomous status by the University Grants Commission (UGC), allowing it to design its own syllabus and conduct examinations independently.",

  "dj sanghvi autonomous hai kya":
      "Haan, DJ Sanghvi ab autonomous college hai — matlab apna syllabus aur exams khud conduct karta hai.",

  "what is cseds department":
      "The Computer Science and Engineering (Data Science) department at DJSCE focuses on modern data analytics, artificial intelligence, and machine learning applications in real-world engineering problems.",

  "cseds department kya hai":
      "CSE-DS matlab Computer Science and Engineering (Data Science) — yahan AI, ML aur Data Analytics par focus hota hai.",

  "placement record of cseds department":
      "The CSE-DS department consistently achieves strong placements, with top recruiters like TCS Digital, Accenture, Deloitte, Morgan Stanley, and J.P. Morgan hiring students.",

  "cseds ke placements kaise hote hai":
      "CSE-DS department ke placements bahut ache hote hain — companies jaise TCS Digital, Deloitte, aur Morgan Stanley yahan se hire karti hain.",

  "average placement package":
      "The average placement package for CSE-DS students ranges between ₹6–8 LPA, with some students securing offers exceeding ₹20 LPA from global tech firms.",

  "average package kitna milta hai":
      "Average package lagbhag ₹6–8 LPA ke beech hota hai, aur top students ko ₹20 LPA+ tak ke offers milte hain.",

  "highest placement package":
      "The highest placement package offered to a DJSCE student has been above ₹30 LPA in recent years.",

  "highest package kitna gaya hai":
      "Highest package ₹30 LPA se upar gaya hai kuch saalon mein.",

  "what are the student clubs":
      "The college hosts several technical and cultural clubs such as IEEE DJSCE, CSI, DJS Racing, DJS Kronos, and CodeCell, promoting learning beyond academics.",

  "dj sanghvi me kaunse clubs hai":
      "DJ Sanghvi me IEEE, CSI, CodeCell, DJS Racing jaise technical clubs aur cultural groups bhi hain.",

  "how is college life at dj sanghvi":
      "College life at DJSCE is vibrant and balanced, with active technical clubs, cultural fests, and supportive faculty encouraging all-round growth.",

  "dj sanghvi ka college life kaisa hai":
      "DJ Sanghvi ka college life kaafi energetic hai — technical clubs, cultural events aur supportive teachers ke saath full fun and learning.",

  "does djsce have cultural fests":
      "Yes, the college hosts popular cultural and technical festivals like TRINITY, DJSCE Hackathon, and Inception every year.",

  "dj sanghvi me fest hote hai kya":
      "Haan, DJ Sanghvi me TRINITY, Hackathon aur Extract jaise bade fests hote hain har saal.",

  "dj sanghvi placement ke baare me batao":
      "DJ Sanghvi ka placement record strong hai — especially CSEDS students ko top companies jaise Deloitte, TCS, aur J.P. Morgan me placement milta hai.",

  "placements kaise hote hai":
      "DJSCE me placements bahut ache hote hain, jahaan bade MNCs aur startups students ko high packages pe hire karte hain.",

  "dj sanghvi me admission kaise hota hai":
      "Admission MHT-CET ya JEE Main ke score ke basis pe hota hai, through Maharashtra CAP process.",

  "dj sanghvi ki fees kitni hai":
      "CSE-DS branch ki annual fees lagbhag ₹2 se ₹2.5 lakh tak hoti hai.",

  "dj sanghvi me hostel milta hai kya":
      "College ke paas hostel nahi hai, lekin Vile Parle aur Andheri area me kaafi accommodation options mil jaate hain.",

  "why choose dj sanghvi":
      "DJ Sanghvi is known for its academic excellence, strong industry connections, supportive faculty, modern infrastructure, and outstanding placement opportunities.",

  "dj sanghvi kyu choose kare":
      "DJ Sanghvi ek reputed college hai jahan accha syllabus, faculty aur placements milte hain — engineering ke liye perfect choice hai."
},

"CSEDS_Lab": {
  "how is the internet connected in the lab":
      "The lab is connected via high-speed wired and Wi-Fi networks, ensuring smooth access to cloud tools and online resources.",
  "lab me internet kaise connected hai":
      "Lab high-speed wired aur Wi-Fi networks se connected hai, jisse cloud tools aur online resources ka smooth access milta hai.",

  "what facilities are available in the lab":
      "The lab has high-performance PCs, cloud computing access, ML libraries, data analytics tools, and dedicated project workstations.",
  "lab me kya-kya facilities hain":
      "Lab me high-performance PCs, cloud computing access, ML libraries, data analytics tools aur project workstations available hain.",

  "how many students can use the lab at a time":
      "The lab can accommodate around 36 students at a time for practical sessions.",
  "ek time pe lab me kitne students use kar sakte hain":
      "Lab ek time pe lagbhag 36 students ko practical sessions ke liye accommodate kar sakta hai.",

  "are the labs updated with latest software":
      "Yes, the labs are regularly updated with the latest data science, AI, and ML tools and software to match industry standards.",
  "kya lab me latest software install hote hain":
      "Haan, lab me regularly latest data science, AI aur ML tools aur software update kiye jaate hain taaki industry standards maintain rahe."
},


    "General": {
      "what is education":
          "Education is the process of facilitating learning, or the acquisition of knowledge, skills, and values.",
      "why is learning important":
          "Learning helps individuals grow, adapt, and improve their personal and professional lives.",
    }
  };

  final String _modelFile = 'assets/all_anim.glb';
  String? _currentAnimation = 'waving'; // starts waving

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      cameras![0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController?.initialize();
    if (!mounted) return;

    setState(() => _isReady = true);

    // 🎵 Greet the user once the camera is initialized
    await Future.delayed(const Duration(seconds: 1));
    _voiceService.playIntroAudio();
  }

  double _similarity(String a, String b) {
    final aWords = a.toLowerCase().split(RegExp(r'\s+'));
    final bWords = b.toLowerCase().split(RegExp(r'\s+'));
    final common = aWords.toSet().intersection(bWords.toSet()).length;
    return common / sqrt(aWords.length * bWords.length);
  }

  /// ✅ Updated: Searches entire FAQ across all topics
  String? _findFaqAnswer(String query) {
    final queryLower = query.toLowerCase().trim();

    final translitMap = {
      "kya": "what",
      "hai": "is",
      "ka": "of",
      "ke": "about",
      "baare": "about",
      "me": "in",
      "batao": "tell",
      "kaun": "who",
      "kaise": "how",
    };

    String normalized = queryLower;
    translitMap.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    double bestScore = 0.0;
    String? bestAnswer;

    // 🔍 Loop through *all* FAQs (not just one object)
    _faq.forEach((objectClass, faqs) {
      for (final entry in faqs.entries) {
        final faqQ = entry.key.toLowerCase();
        final score1 = _similarity(faqQ, queryLower);
        final score2 = _similarity(faqQ, normalized);
        final score = max(score1, score2);
        if (score > bestScore) {
          bestScore = score;
          bestAnswer = entry.value;
        }
      }
    });

    return bestScore > 0.45 ? bestAnswer : null;
  }

  /// 🎤 Handles voice input & response
  Future<void> _handleVoiceQuery() async {
    if (_isListening) return;
    setState(() => _isListening = true);

    setState(() => _currentAnimation = 'talking');

    String? query = await _voiceService.listenUserSpeech();
    if (query == null || query.isEmpty) {
      setState(() {
        _conversation += "\n❌ Couldn't hear properly.\n";
        _isListening = false;
      });
      return;
    }

    setState(() => _conversation += "\n🗣️ You: $query\n");

    XFile? picture = await _cameraController?.takePicture();
    String detected = await _yoloService.detectObject(picture!.path);
    bool objectDetected =
        detected.isNotEmpty && detected.toLowerCase() != "no object detected";

    if (objectDetected) {
      setState(() => _conversation += "📸 Detected: $detected\n");
    } else {
      setState(() =>
          _conversation += "📸 No object detected. I’ll answer generally.\n");
    }

    final isHindi = RegExp(r'[\u0900-\u097F]+').hasMatch(query);
    String reply = "";

    // 🔹 Try FAQ from the *whole list* first
    final faqAnswer = _findFaqAnswer(query);
    if (faqAnswer != null) {
      reply = faqAnswer;
    } else {
      // otherwise, go to Gemini fallback
      final finalPrompt = isHindi
          ? "$query — कृपया विस्तार से बताएं।"
          : "$query in detail.";
      reply =
          await _voiceService.getGeminiReply(finalPrompt, detailed: _isDetailed);
    }

    await _voiceService.speakWithElevenLabs(
      reply,
      rate: _speechRate,
      isHindi: isHindi,
    );

    setState(() {
      _conversation += "🤖 Guide: $reply\n";
      _isListening = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_cameraController!)),

          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.65,
                child: ModelViewer(
                  key: ValueKey(_currentAnimation ?? 'waving'),
                  src: _modelFile,
                  alt: '3D guide',
                  ar: false,
                  autoRotate: false,
                  cameraControls: true,
                  disableZoom: false,
                  backgroundColor: Colors.transparent,
                  animationName: _currentAnimation,
                  autoPlay: true,
                  arScale: ArScale.auto,
                ),
              ),
            ),
          ),

          // Short/Detailed switch
          Positioned(
            top: 60,
            left: 20,
            child: Row(
              children: [
                const Text("Short",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                Switch(
                  activeColor: Colors.orangeAccent,
                  value: _isDetailed,
                  onChanged: (v) => setState(() => _isDetailed = v),
                ),
                const Text("Detailed",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),

          // Chat box
          if (_showChatBox)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _conversation,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),

          // Bottom buttons
          Positioned(
            bottom: 25,
            left: MediaQuery.of(context).size.width / 2 - 140,
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapScreen()),
                    );
                  },
                  child: const Text(
                    "Recommend",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(60, 60),
                    shape: const CircleBorder(),
                  ),
                  onPressed: () => setState(() => _showChatBox = !_showChatBox),
                  child: Icon(
                    _showChatBox ? Icons.chat_bubble : Icons.chat_bubble_outline,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  backgroundColor:
                      _isListening ? Colors.redAccent : Colors.orange,
                  onPressed: _handleVoiceQuery,
                  child: Icon(
                    _isListening ? Icons.hearing : Icons.mic,
                    color: Colors.white,
                    size: 28,
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
