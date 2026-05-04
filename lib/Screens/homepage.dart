import 'package:flutter/material.dart';
import 'playlist_detail_screen.dart';
import 'create_playlist_screen.dart';
import 'review_detail_screen.dart';

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
          title: const Text(
            'Decibel',
            style: TextStyle(
              color: Color(0xFFF3E3B6),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF8282),
            indicatorWeight: 3,
            labelColor: Color(0xFFFF8282),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Música'),
              Tab(text: 'Listas'),
              Tab(text: 'Diário'),
            ],
          ),
        )
            : null,

        body: IndexedStack(
          index: _bottomNavIndex,
          children: [
            _buildHomeTabs(),
            _buildPesquisaFeed(),
            _buildPlaceholderScreen(),
            _buildPlaceholderScreen(),
            _buildPlaceholderScreen(),
          ],
        ),

        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHomeTabs() {
    return TabBarView(
      children: [
        _buildMusicaFeed(),
        _buildListasFeed(),
        _buildDiarioFeed(),
      ],
    );
  }

  Widget _buildMusicaFeed() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildPostCard(
          context,
          userName: 'Sofia Oliveira',
          date: '3 de maio',
          profileImagePath: 'assets/Users/sofia.jpg',
          songTitle: 'All Of The Lights',
          artist: 'Kanye West',
          albumImagePath: 'assets/Covers/mbdtf.jpg',
          rating: 5,
          year: '2010',
          likes: '1 Gosto',
          description: 'Produção cinematográfica pura. O Kanye juntou Rihanna, Kid Cudi, Fergie, Alicia Keys, Elton John... e transformou tudo num espetáculo sonoro épico. O beat é gigantesco, o refrão é viciante e a letra é pesada. Um dos melhores momentos do álbum My Beautiful Dark Twisted Fantasy.',
        ),
        const SizedBox(height: 20),
        _buildPostCard(
          context,
          userName: 'Tiago Mendes',
          date: '14 de abril',
          profileImagePath: 'assets/Users/tiago.jpg',
          songTitle: 'Stronger',
          artist: 'Kanye West',
          albumImagePath: 'assets/Covers/grad.jpg',
          rating: 4,
          year: '2007',
          likes: '3 Gostos',
          description: 'La La La-La... esse sample do Daft Punk é simplesmente perfeito. Kanye pegou num som eletrónico francês e transformou num hino de superação e ego. Um dos maiores bangers da carreira dele e um dos mais importantes do hip-hop dos anos 2000.',
        ),
      ],
    );
  }

  Widget _buildListasFeed() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            const Text(
              'As suas Listas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white54, thickness: 1, height: 10),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaylistDetailScreen()),
                );
              },
              child: _buildPlaylistCard(
                title: 'Favoritos',
                songCount: '4 Músicas',
                imagePath: 'assets/Covers/cdp.jpg',
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8282),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Criar Lista',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
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
              _buildDiaryCard(
                title: 'Devil In A New Dress',
                artist: 'Artist',
                rating: 4,
                imagePath: 'assets/Covers/mbdtf.jpg',
              ),
              const SizedBox(height: 15),
              _buildDiaryCard(
                title: 'Flashing Lights',
                artist: 'Artist',
                rating: 5,
                imagePath: 'assets/Covers/grad.jpg',
              ),
            ],
          ),
        ),

        _buildMonthHeader('Março 2026'),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildDiaryCard(
            title: 'All Falls Down',
            artist: 'Kanye West',
            rating: 4,
            imagePath: 'assets/Covers/cdp.jpg',
          ),
        ),

        _buildMonthHeader('Fevereiro 2026'),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildDiaryCard(
            title: 'Stronger',
            artist: 'Kanye West',
            rating: 5,
            imagePath: 'assets/Covers/grad.jpg',
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(
      BuildContext context, {
        required String userName,
        required String date,
        required String profileImagePath,
        required String songTitle,
        required String artist,
        required String albumImagePath,
        required String description,
        required int rating,
        required String year,
        required String likes,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewDetailScreen(
              userName: userName,
              date: date,
              profileImagePath: profileImagePath,
              songTitle: songTitle,
              artist: artist,
              year: year,
              rating: rating,
              likes: likes,
              albumImagePath: albumImagePath,
              fullReviewText: description,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF263D4A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  backgroundImage: AssetImage(profileImagePath),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(color: Color(0xFFF3E3B6), fontWeight: FontWeight.bold)),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(albumImagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(songTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(artist, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFF8282), size: 20)),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard({
    required String title,
    required String songCount,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF263D4A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                  style: const TextStyle(
                      color: Color(0xFFF3E3B6),
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),
              const SizedBox(height: 4),
              Text(
                  songCount,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  )
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard({
    required String title,
    required String artist,
    required int rating,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF263D4A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: List.generate(5, (index) {
                    if (index < rating) {
                      return const Icon(Icons.star, color: Color(0xFFFF8282), size: 20);
                    } else {
                      return const Icon(Icons.star_border, color: Color(0xFFFF8282), size: 20);
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF292929),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomIcon(Icons.home_outlined, 0),
            _buildBottomIcon(Icons.search, 1),

            GestureDetector(
              onTap: () => setState(() => _bottomNavIndex = 2),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF3E3B6), width: 2),
                ),
                child: const Icon(Icons.add, color: Color(0xFFF3E3B6), size: 28),
              ),
            ),

            _buildBottomIcon(Icons.notifications_none, 3),
            _buildBottomIcon(Icons.person_outline, 4),
          ],
        ),
      ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.1,
                children: [
                  _buildGenreCard('Hip-Hop'),
                  _buildGenreCard('Rap'),
                  _buildGenreCard('R&B'),
                  _buildGenreCard('Rock'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreCard(String genre) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E3B6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, int index) {
    final isSelected = _bottomNavIndex == index;
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? const Color(0xFFFF8282) : Colors.grey,
      iconSize: 30,
      onPressed: () => setState(() => _bottomNavIndex = index),
    );
  }

  Widget _buildMonthHeader(String monthYear) {
    return Container(
      width: double.infinity,
      color: Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        monthYear,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen() {
    return Center(
      child: Text(
        'Ecrã da opção $_bottomNavIndex',
        style: const TextStyle(color: Color(0xFFF3E3B6), fontSize: 24),
      ),
    );
  }
}