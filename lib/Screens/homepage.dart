import 'package:flutter/material.dart';
import 'playlist_detail_screen.dart';
import 'create_playlist_screen.dart';
import 'review_detail_screen.dart';
import 'add_music_screen.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E3746),

        appBar: _bottomNavIndex == 0
            ? AppBar(
          backgroundColor: const Color(0xFF1E3746),
          elevation: 0,
          title: const Text('Decibel', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 26, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF8282),
            indicatorWeight: 3,
            labelColor: Color(0xFFFF8282),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [Tab(text: 'Música'), Tab(text: 'Listas'), Tab(text: 'Diário')],
          ),
        )
            : _bottomNavIndex == 3
            ? AppBar(
          backgroundColor: const Color(0xFF1E3746),
          elevation: 0,
          centerTitle: true,
          title: const Text('Notificações', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 24, fontWeight: FontWeight.bold)),
          actions: const [Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.filter_alt_outlined, color: Color(0xFFF3E3B6), size: 30))],
        )
            : _bottomNavIndex == 4
            ? AppBar(
          backgroundColor: const Color(0xFF1E3746),
          elevation: 0,
          leading: const Icon(Icons.settings_outlined, color: Color(0xFFF3E3B6), size: 30),
          title: const Text('Name', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 24, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: const [Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.more_horiz, color: Color(0xFFF3E3B6), size: 30))],
        )
            : null,

        body: IndexedStack(
          index: _bottomNavIndex,
          children: [
            _buildHomeTabs(),
            _buildPesquisaFeed(),
            const SizedBox.shrink(),
            _buildNotificacoesFeed(),
            _buildPerfilFeed(),
          ],
        ),

        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHomeTabs() {
    return TabBarView(children: [_buildMusicaFeed(), _buildListasFeed(), _buildDiarioFeed()]);
  }

  Widget _buildMusicaFeed() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildPostCard(context, userName: 'Sofia Oliveira', date: '3 de maio', profileImagePath: 'assets/Users/sofia.jpg', songTitle: 'All Of The Lights', artist: 'Kanye West', albumImagePath: 'assets/Covers/mbdtf.jpg', rating: 5, year: '2010', likes: '1 Gosto', description: 'Produção cinematográfica pura. O Kanye juntou Rihanna, Kid Cudi, Fergie, Alicia Keys, Elton John...'),
        const SizedBox(height: 20),
        _buildPostCard(context, userName: 'Tiago Mendes', date: '14 de abril', profileImagePath: 'assets/Users/tiago.jpg', songTitle: 'Stronger', artist: 'Kanye West', albumImagePath: 'assets/Covers/grad.jpg', rating: 4, year: '2007', likes: '3 Gostos', description: 'O sample do Daft Punk é simplesmente perfeito.'),
      ],
    );
  }

  Widget _buildListasFeed() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            const Text('As suas Listas', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white54, thickness: 1),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaylistDetailScreen())),
              child: _buildPlaylistCard(title: 'Favoritos', songCount: '4 Músicas', imagePath: 'assets/Covers/cdp.jpg'),
            ),
          ],
        ),
        Positioned(
          bottom: 20, right: 20,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePlaylistScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8282),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Criar Lista', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDiarioFeed() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildMonthHeader('Maio 2026'),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildDiaryCard(title: 'Devil In A New Dress', artist: 'Artist', rating: 4, imagePath: 'assets/Covers/mbdtf.jpg'),
              const SizedBox(height: 15),
              _buildDiaryCard(title: 'Flashing Lights', artist: 'Artist', rating: 5, imagePath: 'assets/Covers/grad.jpg'),
            ],
          ),
        ),
        _buildMonthHeader('Março 2026'),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildDiaryCard(title: 'All Falls Down', artist: 'Kanye West', rating: 4, imagePath: 'assets/Covers/cdp.jpg'),
        ),
        _buildMonthHeader('Fevereiro 2026'),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildDiaryCard(title: 'Stronger', artist: 'Kanye West', rating: 5, imagePath: 'assets/Covers/grad.jpg'),
        ),
      ],
    );
  }

  Widget _buildPesquisaFeed() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pesquisa',
                hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF323232),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.1,
                children: [ _buildGenreCard('Hip-Hop'), _buildGenreCard('Rap'), _buildGenreCard('R&B'), _buildGenreCard('Rock') ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificacoesFeed() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _buildNotificationItem(userName: 'Tiago Mendes', action: 'gostou da tua Review', time: '2h atrás', profileImagePath: 'assets/Users/tiago.jpg'),
        const SizedBox(height: 15),
        _buildNotificationItem(userName: 'Sofia Oliveira', action: 'adicionou uma Review', time: '2 dias atrás', profileImagePath: 'assets/Users/sofia.jpg'),
        const SizedBox(height: 15),
        _buildNotificationItem(userName: 'Sofia Oliveira', action: 'adicionou uma Review', time: '5 dias atrás', profileImagePath: 'assets/Users/sofia.jpg'),
      ],
    );
  }

  Widget _buildPerfilFeed() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/Users/sofia.jpg')),
          const SizedBox(height: 15),
          const Text('Ambrosio Milfonte', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('@Username', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 15),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('4 ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Reviews', style: TextStyle(color: Color(0xFFF3E3B6))),
              SizedBox(width: 30),
              Text('2 ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Seguidores', style: TextStyle(color: Color(0xFFF3E3B6))),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey, height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Artistas Favoritos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                const CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/Artists/ye.jpg')),
                const SizedBox(height: 8),
                const Text('Kanye West', style: TextStyle(color: Color(0xFFF3E3B6), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Músicas Favoritas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFavSong('All Falls Down', 'assets/Covers/cdp.jpg'),
                    _buildFavSong('Devil in a new dress', 'assets/Covers/mbdtf.jpg'),
                    _buildFavSong('Stronger', 'assets/Covers/grad.jpg'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuOption('Listas'),
          _buildMenuOption('Diário'),
          _buildMenuOption('A seguir'),
          const Divider(color: Colors.grey, height: 1),
        ],
      ),
    );
  }



  Widget _buildFavSong(String title, String img) {
    return Column(
      children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover))),
        const SizedBox(height: 8),
        SizedBox(width: 80, child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFF3E3B6), fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2)),
      ],
    );
  }

  Widget _buildMenuOption(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(color: Color(0xFF263D4A), border: Border(top: BorderSide(color: Colors.white10))),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPostCard(BuildContext context, {required String userName, required String date, required String profileImagePath, required String songTitle, required String artist, required String albumImagePath, required String description, required int rating, required String year, required String likes}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetailScreen(userName: userName, date: date, profileImagePath: profileImagePath, songTitle: songTitle, artist: artist, year: year, rating: rating, likes: likes, albumImagePath: albumImagePath, fullReviewText: description))),
      child: Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF263D4A), borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [CircleAvatar(radius: 20, backgroundImage: AssetImage(profileImagePath)), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(userName, style: const TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold)), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12))])]),
          const SizedBox(height: 20),
          Row(children: [Container(width: 70, height: 70, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: AssetImage(albumImagePath), fit: BoxFit.cover))), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(songTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text(artist, style: const TextStyle(color: Colors.grey, fontSize: 14)), Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Color(0xFFFF8282), size: 20)))])),]),
          const SizedBox(height: 15),
          Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildPlaylistCard({required String title, required String songCount, required String imagePath}) {
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF263D4A), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold)), Text(songCount, style: const TextStyle(color: Colors.grey))]), Container(width: 50, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover)))]));
  }

  Widget _buildDiaryCard({required String title, required String artist, required int rating, required String imagePath}) {
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF263D4A), borderRadius: BorderRadius.circular(10)), child: Row(children: [Container(width: 70, height: 70, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover))), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(artist, style: const TextStyle(color: Colors.grey)), Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: const Color(0xFFFF8282), size: 20)))]))]));
  }

  Widget _buildNotificationItem({required String userName, required String action, required String time, required String profileImagePath}) {
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Row(children: [CircleAvatar(radius: 25, backgroundImage: AssetImage(profileImagePath)), const SizedBox(width: 15), Expanded(child: RichText(text: TextSpan(style: const TextStyle(color: Color(0xFF1E3746), fontSize: 14), children: [TextSpan(text: '$userName ', style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: action)]))), Text(time, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))]));
  }

  Widget _buildMonthHeader(String txt) => Container(width: double.infinity, color: Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), child: Text(txt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));

  Widget _buildGenreCard(String genre) {
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFF3E3B6), borderRadius: BorderRadius.circular(15)), child: Text(genre, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10), color: const Color(0xFF292929),
      child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildBottomIcon(Icons.home_outlined, 0),
        _buildBottomIcon(Icons.search, 1),
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMusicScreen())), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF3E3B6), width: 2)), child: const Icon(Icons.add, color: Color(0xFFF3E3B6), size: 28))),
        _buildBottomIcon(Icons.notifications_none, 3),
        _buildBottomIcon(Icons.person_outline, 4),
      ])),
    );
  }

  Widget _buildBottomIcon(IconData icon, int idx) => IconButton(icon: Icon(icon), color: _bottomNavIndex == idx ? const Color(0xFFFF8282) : Colors.grey, onPressed: () => setState(() => _bottomNavIndex = idx));

  Widget _buildPlaceholderScreen() => const Center(child: Text('Em breve...', style: TextStyle(color: Colors.white)));
}