// lib/features/library/presentation/screens/library_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/library/presentation/providers/library_provider.dart';
import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';

import '../../domain/repositories/library_repository.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late final AnimationController _menuController;
  late final AnimationController _fabController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fabAnimation;
  late final Animation<double> _fadeAnimation;

  bool _isMenuOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Debounce timer for search
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLibrary();
  }

  void _initializeAnimations() {
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutCubic,
    ));
    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeLibrary() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LibraryProvider>(context, listen: false);
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleMenu() {
    _fabController.forward().then((_) => _fabController.reverse());
    if (_isMenuOpen) {
      _menuController.reverse();
    } else {
      _menuController.forward();
    }
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _onSearchChanged(String value, LibraryProvider provider) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty) {
        provider.toggleSearch(false);
      } else {
        provider.searchItems(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        return Scaffold(
          backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () => libraryProvider.refresh(),
            color: AppTheme.primaryBrandColor,
            backgroundColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
            child: Stack(
              children: [
                // Main content
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Enhanced App Bar
                    _buildAppBar(libraryProvider, isDarkMode),

                    // Error handling
                    if (libraryProvider.hasError)
                      _buildErrorSection(libraryProvider, isDarkMode),

                    // Category Filter Chips
                    if (!libraryProvider.isSearching && !libraryProvider.hasError)
                      _buildCategorySection(libraryProvider, isDarkMode),

                    // Statistics Bar
                    if (!libraryProvider.isSearching && !libraryProvider.hasError && libraryProvider.hasItems)
                      _buildStatisticsBar(libraryProvider, isDarkMode),

                    // Content
                    _buildContent(libraryProvider, isDarkMode),
                  ],
                ),

                // Menu backdrop
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    final clampedOpacity = _fadeAnimation.value.clamp(0.0, 1.0);
                    return clampedOpacity > 0
                        ? GestureDetector(
                      onTap: _toggleMenu,
                      child: Container(
                        color: Colors.black.withOpacity(clampedOpacity),
                      ),
                    )
                        : const SizedBox.shrink();
                  },
                ),

                // Sliding filter menu
                SlideTransition(
                  position: _slideAnimation,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: EnhancedFilterMenu(
                      provider: libraryProvider,
                      onFilterSelected: (category) {
                        libraryProvider.filterItems(category);
                        _toggleMenu();
                      },
                      onSortChanged: (sortOption) {
                        libraryProvider.setSortOption(sortOption);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(isDarkMode),
        );
      },
    );
  }

  Widget _buildAppBar(LibraryProvider provider, bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: provider.isSearching ? 140.h : 100.h,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildAnimatedIconButton(
        icon: Icons.arrow_back_ios_new,
        onPressed: () => Navigator.pop(context),
        isDarkMode: isDarkMode,
      ),
      actions: [
        _buildAnimatedIconButton(
          icon: provider.isSearching ? Icons.close : Icons.search,
          onPressed: () {
            if (provider.isSearching) {
              _searchController.clear();
              _searchFocusNode.unfocus();
            }
            provider.toggleSearch(!provider.isSearching);
          },
          isDarkMode: isDarkMode,
        ),
        _buildAnimatedIconButton(
          icon: provider.viewMode == LibraryViewMode.grid ? Icons.view_list : Icons.grid_view,
          onPressed: () {
            provider.setViewMode(
                provider.viewMode == LibraryViewMode.grid
                    ? LibraryViewMode.list
                    : LibraryViewMode.grid
            );
          },
          isDarkMode: isDarkMode,
        ),
        SizedBox(width: 16.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: provider.isSearching ? null : AnimatedOpacity(
          opacity: provider.isSearching ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            'المكتبة',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppTheme.primaryBrandColor,
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        background: provider.isSearching
            ? Padding(
          padding: EdgeInsets.fromLTRB(16.w, 80.h, 16.w, 20.h),
          child: _buildSearchBar(provider, isDarkMode),
        )
            : null,
      ),
    );
  }

  Widget _buildSearchBar(LibraryProvider provider, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [AppTheme.darkCardColor, AppTheme.darkCardColor.withOpacity(0.95)]
              : [Colors.white, Colors.white.withOpacity(0.98)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: AppTheme.primaryBrandColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrandColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        onChanged: (value) => _onSearchChanged(value, provider),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: 'Tajawal',
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث في المكتبة...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
            fontFamily: 'Tajawal',
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: isDarkMode ? Colors.white54 : Colors.grey),
            onPressed: () {
              _searchController.clear();
              provider.toggleSearch(false);
            },
          )
              : Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBrandColor, AppTheme.secondaryBrandColor],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: 20.r,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(LibraryProvider provider, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60.h,
        margin: EdgeInsets.symmetric(vertical: 10.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          physics: const BouncingScrollPhysics(),
          itemCount: provider.categories.length,
          itemBuilder: (context, index) {
            final category = provider.categories[index];
            return _buildCategoryChip(category, provider, isDarkMode);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(CategoryEntity category, LibraryProvider provider, bool isDarkMode) {
    final bool isSelected = category.name == provider.currentCategory;
    final Color categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xff')));

    return Container(
      margin: EdgeInsets.only(left: 12.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [categoryColor, categoryColor.withOpacity(0.8)])
              : null,
          color: isSelected ? null : (isDarkMode ? AppTheme.darkCardColor : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? categoryColor : categoryColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? categoryColor.withOpacity(0.4)
                  : (isDarkMode ? Colors.black : Colors.grey.shade300).withOpacity(0.2),
              blurRadius: isSelected ? 12 : 4,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => provider.filterItems(category.name),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.getCategoryIcon(category.name),
                    size: 16.r,
                    color: isSelected ? Colors.white : categoryColor,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : categoryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsBar(LibraryProvider provider, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [AppTheme.darkCardColor.withOpacity(0.8), AppTheme.darkCardColor.withOpacity(0.6)]
                : [AppTheme.primaryBrandColor.withOpacity(0.1), AppTheme.primaryBrandColor.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.primaryBrandColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(
              Icons.library_books,
              provider.displayedItemsCount.toString(),
              'عنصر',
              isDarkMode,
            ),
            _buildStatItem(
              Icons.download,
              provider.totalDownloads.toString(),
              'تحميل',
              isDarkMode,
            ),
            _buildStatItem(
              Icons.category,
              (provider.categories.length - 1).toString(),
              'فئة',
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.r,
          color: AppTheme.primaryBrandColor,
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12.sp,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(LibraryProvider provider, bool isDarkMode) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48.r,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 12.h),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.red.shade700,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              provider.errorMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? Colors.white70 : Colors.red.shade600,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrandColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(LibraryProvider provider, bool isDarkMode) {
    if (provider.isLoading && !provider.hasItems) {
      return _buildLoadingSection(isDarkMode);
    }

    if (provider.isEmpty && !provider.isLoading) {
      return _buildEmptySection(provider, isDarkMode);
    }

    // Build the grid or list based on view mode
    return provider.viewMode == LibraryViewMode.grid
        ? _buildGridContent(provider, isDarkMode)
        : _buildListContent(provider, isDarkMode);
  }

  Widget _buildLoadingSection(bool isDarkMode) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBrandColor, AppTheme.secondaryBrandColor],
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'جاري تحميل المكتبة...',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontFamily: 'Tajawal',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(LibraryProvider provider, bool isDarkMode) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.grey.shade300).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                provider.isSearching ? Icons.search_off : Icons.library_books_outlined,
                size: 80.r,
                color: AppTheme.primaryBrandColor.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              provider.isSearching
                  ? 'لا توجد نتائج للبحث'
                  : 'لا توجد عناصر لعرضها',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontFamily: 'Tajawal',
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              provider.isSearching
                  ? 'جرب كلمات مفتاحية أخرى'
                  : 'تأكد من اتصال الإنترنت وحاول مرة أخرى',
              style: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
                fontFamily: 'Tajawal',
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            if (!provider.isSearching) ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => provider.refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'إعادة التحميل',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrandColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridContent(LibraryProvider provider, bool isDarkMode) {
    return SliverPadding(
      padding: EdgeInsets.all(16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 20.h,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final item = provider.items[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                final clampedOpacity = value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: clampedOpacity,
                    child: EnhancedLibraryItemCard(
                      item: item,
                      isDarkMode: isDarkMode,
                      index: index,
                      viewMode: LibraryViewMode.grid,
                      onTap: () => _handleItemTap(item, provider),
                      onDownload: () => _handleDownload(item, provider),
                    ),
                  ),
                );
              },
            );
          },
          childCount: provider.items.length,
        ),
      ),
    );
  }

  Widget _buildListContent(LibraryProvider provider, bool isDarkMode) {
    return SliverPadding(
      padding: EdgeInsets.all(16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final item = provider.items[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final clampedOpacity = value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(-50 * (1 - value), 0),
                  child: Opacity(
                    opacity: clampedOpacity,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: EnhancedLibraryItemCard(
                        item: item,
                        isDarkMode: isDarkMode,
                        index: index,
                        viewMode: LibraryViewMode.list,
                        onTap: () => _handleItemTap(item, provider),
                        onDownload: () => _handleDownload(item, provider),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          childCount: provider.items.length,
        ),
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.8 + (0.2 * clampedValue),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [AppTheme.darkCardColor.withOpacity(0.9), AppTheme.darkCardColor.withOpacity(0.7)]
                      : [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppTheme.primaryBrandColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.grey.shade300).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isDarkMode ? Colors.white : AppTheme.primaryBrandColor,
                size: 20.r,
              ),
            ),
            onPressed: onPressed,
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBrandColor, AppTheme.secondaryBrandColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrandColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _toggleMenu,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AnimatedRotation(
            turns: _isMenuOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isMenuOpen ? Icons.close : Icons.tune,
              color: Colors.white,
              size: 24.r,
            ),
          ),
        ),
      ),
    );
  }

  void _handleItemTap(LibraryItemEntity item, LibraryProvider provider) {
    // Show item details dialog or navigate to details screen
    showDialog(
      context: context,
      builder: (context) => LibraryItemDetailsDialog(
        item: item,
        onDownload: () => _handleDownload(item, provider),
      ),
    );
  }

  void _handleDownload(LibraryItemEntity item, LibraryProvider provider) async {
    final success = await provider.downloadBook(item.id, item.title);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'بدأ تحميل "${item.title}"'
                : 'فشل في تحميل "${item.title}"',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }
}

// Enhanced Library Item Card
class EnhancedLibraryItemCard extends StatefulWidget {
  final LibraryItemEntity item;
  final bool isDarkMode;
  final int index;
  final LibraryViewMode viewMode;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const EnhancedLibraryItemCard({
    Key? key,
    required this.item,
    required this.isDarkMode,
    required this.index,
    required this.viewMode,
    this.onTap,
    this.onDownload,
  }) : super(key: key);

  @override
  State<EnhancedLibraryItemCard> createState() => _EnhancedLibraryItemCardState();
}

class _EnhancedLibraryItemCardState extends State<EnhancedLibraryItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: 6.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    switch (widget.item.category.toLowerCase()) {
      case 'كتب':
      case 'books':
        return AppTheme.primaryBrandColor;
      case 'مقالات':
      case 'articles':
        return AppTheme.secondaryBrandColor;
      case 'أبحاث':
      case 'research':
        return const Color(0xFFDC2626);
      case 'قصص':
      case 'stories':
        return const Color(0xFF7C3AED);
      case 'الشعر':
      case 'poetry':
        return const Color(0xFFEA580C);
      default:
        return AppTheme.primaryBrandColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Hero(
      tag: 'library_item_${widget.item.id}',
      child: GestureDetector(
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) => _hoverController.reverse(),
        onTapCancel: () => _hoverController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: widget.viewMode == LibraryViewMode.list ? 120.h : null,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDarkMode
                        ? [const Color(0xFF2D2D3A), const Color(0xFF25252F)]
                        : [Colors.white, const Color(0xFFFFFFF8)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.15),
                      blurRadius: _elevationAnimation.value,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: (widget.isDarkMode ? Colors.black : Colors.grey.shade300).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: categoryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: widget.viewMode == LibraryViewMode.grid
                      ? _buildGridCard(categoryColor)
                      : _buildListCard(categoryColor),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridCard(Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image section
        Expanded(
          flex: 3,
          child: _buildImageSection(categoryColor),
        ),
        // Content section
        Expanded(
          flex: 2,
          child: _buildContentSection(categoryColor, isCompact: true),
        ),
      ],
    );
  }

  Widget _buildListCard(Color categoryColor) {
    return Row(
      children: [
        // Image section
        Container(
          width: 80.w,
          height: double.infinity,
          child: _buildImageSection(categoryColor),
        ),
        // Content section
        Expanded(
          child: _buildContentSection(categoryColor, isCompact: false),
        ),
      ],
    );
  }

  Widget _buildImageSection(Color categoryColor) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            widget.item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withOpacity(0.3),
                      categoryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(),
                    color: categoryColor.withOpacity(0.6),
                    size: widget.viewMode == LibraryViewMode.grid ? 32.r : 24.r,
                  ),
                ),
              );
            },
          ),
        ),
        // Category badge
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoryColor, categoryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.item.category,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.viewMode == LibraryViewMode.grid ? 8.sp : 10.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(Color categoryColor, {required bool isCompact}) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and author
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : const Color(0xFF2D2D3A),
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 11.sp : 14.sp,
                    fontFamily: 'Tajawal',
                    height: 1.2,
                  ),
                  maxLines: isCompact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: isCompact ? 10.r : 12.r,
                      color: widget.isDarkMode ? Colors.white60 : const Color(0xFF8E8E9A),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        widget.item.author,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white60 : const Color(0xFF8E8E9A),
                          fontSize: isCompact ? 9.sp : 12.sp,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (!isCompact && widget.item.rating != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12.r,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        widget.item.rating!.toStringAsFixed(1),
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 10.sp,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      if (widget.item.downloads != null) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.download,
                          size: 12.r,
                          color: widget.isDarkMode ? Colors.white54 : Colors.black38,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${widget.item.downloads}',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white54 : Colors.black38,
                            fontSize: 10.sp,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Action button
          Container(
            width: double.infinity,
            height: isCompact ? 24.h : 32.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoryColor, categoryColor.withOpacity(0.8)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: widget.onDownload,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download,
                        color: Colors.white,
                        size: isCompact ? 12.r : 16.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'تحميل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 9.sp : 12.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.item.category.toLowerCase()) {
      case 'كتب':
      case 'books':
        return Icons.book;
      case 'مقالات':
      case 'articles':
        return Icons.article;
      case 'أبحاث':
      case 'research':
        return Icons.science;
      case 'قصص':
      case 'stories':
        return Icons.auto_stories;
      case 'الشعر':
      case 'poetry':
        return Icons.format_quote;
      default:
        return Icons.library_books;
    }
  }
}

// Enhanced Filter Menu
class EnhancedFilterMenu extends StatelessWidget {
  final LibraryProvider provider;
  final Function(String) onFilterSelected;
  final Function(SortOption) onSortChanged;
  final bool isDarkMode;

  const EnhancedFilterMenu({
    Key? key,
    required this.provider,
    required this.onFilterSelected,
    required this.onSortChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.75.sw,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [AppTheme.darkBackgroundColor, AppTheme.darkBackgroundColor.withOpacity(0.95)]
              : [AppTheme.lightBackgroundColor, AppTheme.lightBackgroundColor.withOpacity(0.98)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          bottomLeft: Radius.circular(30.r),
        ),
        border: Border.all(
          color: AppTheme.primaryBrandColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrandColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(-10, 0),
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 80.h, 20.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header
            _buildHeader(),
            SizedBox(height: 30.h),

            // Categories
            _buildSectionTitle('الفئات'),
            SizedBox(height: 16.h),
            ...provider.categories.map((category) => _buildFilterButton(category)),

            SizedBox(height: 30.h),

            // Sort options
            _buildSectionTitle('ترتيب حسب'),
            SizedBox(height: 16.h),
            ...SortOption.values.map((option) => _buildSortButton(option)),

            SizedBox(height: 30.h),

            // Statistics
            _buildStatisticsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBrandColor, AppTheme.secondaryBrandColor],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrandColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.tune,
            color: Colors.white,
            size: 24.r,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'تصفية وترتيب',
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppTheme.primaryBrandColor,
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
                fontFamily: 'Tajawal',
              ),
            ),
            Text(
              '${provider.displayedItemsCount} من أصل ${provider.totalItems}',
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : Colors.black54,
                fontSize: 12.sp,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: isDarkMode ? Colors.white : AppTheme.primaryBrandColor,
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildFilterButton(CategoryEntity category) {
    final bool isSelected = category.name == provider.currentCategory;
    final Color categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xff')));

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [categoryColor, categoryColor.withOpacity(0.8)])
              : null,
          color: isSelected ? null : (isDarkMode ? AppTheme.darkCardColor.withOpacity(0.7) : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? categoryColor : categoryColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? categoryColor.withOpacity(0.4)
                  : (isDarkMode ? Colors.black : Colors.grey.shade300).withOpacity(0.2),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => onFilterSelected(category.name),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          provider.getCategoryIcon(category.name),
                          size: 16.r,
                          color: isSelected ? Colors.white : categoryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${provider.categoryStats[category.id] ?? 0}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected ? Colors.white70 : (isDarkMode ? Colors.white60 : Colors.black54),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontFamily: 'Tajawal',
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton(SortOption option) {
    final bool isSelected = option == provider.sortOption;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [AppTheme.primaryBrandColor, AppTheme.primaryBrandColor.withOpacity(0.8)])
              : null,
          color: isSelected ? null : (isDarkMode ? AppTheme.darkCardColor.withOpacity(0.7) : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBrandColor : AppTheme.primaryBrandColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryBrandColor.withOpacity(0.4)
                  : (isDarkMode ? Colors.black : Colors.grey.shade300).withOpacity(0.2),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => onSortChanged(option),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : AppTheme.primaryBrandColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getSortIcon(option),
                      size: 16.r,
                      color: isSelected ? Colors.white : AppTheme.primaryBrandColor,
                    ),
                  ),
                  Text(
                    provider.getSortOptionName(option),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontFamily: 'Tajawal',
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [AppTheme.darkCardColor.withOpacity(0.7), AppTheme.darkCardColor.withOpacity(0.5)]
              : [AppTheme.primaryBrandColor.withOpacity(0.1), AppTheme.primaryBrandColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryBrandColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'إحصائيات المكتبة',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppTheme.primaryBrandColor,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 12.h),
          _buildStatRow(Icons.library_books, 'إجمالي العناصر', provider.totalItems.toString()),
          _buildStatRow(Icons.download, 'إجمالي التحميلات', provider.totalDownloads.toString()),
          _buildStatRow(Icons.category, 'عدد الفئات', (provider.categories.length - 1).toString()),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryBrandColor,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
          ),
          Row(
            children: [
              Icon(
                icon,
                size: 14.r,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return Icons.new_releases;
      case SortOption.oldest:
        return Icons.history;
      case SortOption.title:
        return Icons.sort_by_alpha;
      case SortOption.author:
        return Icons.person;
      case SortOption.rating:
        return Icons.star;
      case SortOption.downloads:
        return Icons.download;
    }
  }
}

// Library Item Details Dialog
class LibraryItemDetailsDialog extends StatelessWidget {
  final LibraryItemEntity item;
  final VoidCallback? onDownload;

  const LibraryItemDetailsDialog({
    Key? key,
    required this.item,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 0.9.sw,
        constraints: BoxConstraints(maxHeight: 0.8.sh),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppTheme.darkCardColor, AppTheme.darkCardColor.withOpacity(0.95)]
                : [Colors.white, Colors.white.withOpacity(0.98)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrandColor.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with image
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                      child: Image.network(
                        item.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryBrandColor.withOpacity(0.3),
                                  AppTheme.primaryBrandColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.library_books,
                                size: 64.r,
                                color: AppTheme.primaryBrandColor.withOpacity(0.6),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: 16.h,
                      left: 16.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white, size: 20.r),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryBrandColor, AppTheme.primaryBrandColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrandColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Author
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16.r,
                          color: AppTheme.primaryBrandColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          item.author,
                          style: TextStyle(
                            color: AppTheme.primaryBrandColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Rating and downloads
                    Row(
                      children: [
                        if (item.rating != null) ...[
                          Icon(Icons.star, color: Colors.amber, size: 18.r),
                          SizedBox(width: 4.w),
                          Text(
                            item.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                        if (item.downloads != null) ...[
                          SizedBox(width: 16.w),
                          Icon(Icons.download, color: AppTheme.primaryBrandColor, size: 18.r),
                          SizedBox(width: 4.w),
                          Text(
                            '${item.downloads} تحميل',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (item.description != null && item.description!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text(
                        'الوصف',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppTheme.primaryBrandColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 14.sp,
                          fontFamily: 'Tajawal',
                          height: 1.5,
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // Download button
                    Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBrandColor, AppTheme.secondaryBrandColor],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBrandColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24.r),
                          onTap: () {
                            Navigator.of(context).pop();
                            onDownload?.call();
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.download,
                                  color: Colors.white,
                                  size: 24.r,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'تحميل الآن',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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