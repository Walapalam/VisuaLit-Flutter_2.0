import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationState {
  final int totalPages;
  final int currentPage;
  final bool isPaginatedMode;
  final double viewportHeight;

  const PaginationState({
    this.totalPages = 1,
    this.currentPage = 1,
    this.isPaginatedMode = false,
    this.viewportHeight = 0,
  });

  PaginationState copyWith({
    int? totalPages,
    int? currentPage,
    bool? isPaginatedMode,
    double? viewportHeight,
  }) {
    return PaginationState(
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isPaginatedMode: isPaginatedMode ?? this.isPaginatedMode,
      viewportHeight: viewportHeight ?? this.viewportHeight,
    );
  }
}

class PaginationController extends StateNotifier<PaginationState> {
  PaginationController() : super(const PaginationState());

  void updateMetrics(ScrollMetrics metrics) {
    if (metrics.viewportDimension <= 0) return;

    final viewportHeight = metrics.viewportDimension;
    final totalContentHeight =
        metrics.maxScrollExtent +
        viewportHeight; // maxScrollExtent is (content - viewport)

    // Calculate total pages
    // We use ceil to ensure the last bit of content gets its own page
    final totalPages = (totalContentHeight / viewportHeight).ceil();

    // Calculate current page (1-based)
    // We add a small epsilon to handle precision issues
    final currentPage = ((metrics.pixels + 1) / viewportHeight).floor() + 1;

    // Only update if changed to avoid unnecessary rebuilds
    if (state.totalPages != totalPages ||
        state.currentPage != currentPage ||
        state.viewportHeight != viewportHeight) {
      state = state.copyWith(
        totalPages: totalPages > 0 ? totalPages : 1,
        currentPage: currentPage.clamp(1, totalPages > 0 ? totalPages : 1),
        viewportHeight: viewportHeight,
      );
    }
  }

  void togglePaginationMode() {
    state = state.copyWith(isPaginatedMode: !state.isPaginatedMode);
  }

  void setPaginationMode(bool enabled) {
    state = state.copyWith(isPaginatedMode: enabled);
  }

  void updatePage(int pageIndex) {
    state = state.copyWith(currentPage: pageIndex + 1); // 1-based
  }

  void updateTotalPages(int totalPages) {
    state = state.copyWith(totalPages: totalPages);
  }
}

final paginationControllerProvider =
    StateNotifierProvider<PaginationController, PaginationState>((ref) {
      return PaginationController();
    });
