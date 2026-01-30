class ClientHomeState {
  final int selectedTab;
  final bool isLoading;

  const ClientHomeState({
    this.selectedTab = 0,
    this.isLoading = false,
  });

  ClientHomeState copyWith({
    int? selectedTab,
    bool? isLoading,
  }) {
    return ClientHomeState(
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
