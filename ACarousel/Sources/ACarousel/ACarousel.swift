/**
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import SwiftUI


@available(iOS 18.0, OSX 10.15, *)
public struct ACarousel<Data, ID, Content> : View where Data : RandomAccessCollection, ID : Hashable, Content : View {
    
    @ObservedObject
    private var viewModel: ACarouselViewModel<Data, ID>
    private let content: (Data.Element) -> Content
    private let bottomFirstClick: (Data.Element, Int) -> ()
    private let bottomSecondClick: (Data.Element, Int) -> ()
    public var body: some View {
        GeometryReader { proxy -> AnyView in
            viewModel.viewSize = proxy.size
            return AnyView(generateContent(proxy: proxy))
        }.clipped()
    }
    struct CircleValues {
        var scale = 1.0
        var offset = 0.0
    }
    private func generateContent(proxy: GeometryProxy) -> some View {
        HStack(spacing: viewModel.spacing) {
            ForEach(0..<viewModel.data.count, id: \.self) { index in
                ZStack {
                    if viewModel.dragOffsetYs[index] != 0 {
                        HStack(spacing: 48) {
                            VStack {
                                Spacer()
                                if #available(iOS 18.0, *) {
                                    Image(systemName: "trash.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .symbolEffect(.breathe, options: .speed(1.5))
                                        .foregroundStyle(Color.red)
                                        .onTapGesture {
                                            viewModel.dragOffsetYs[index] = 0
                                            bottomFirstClick(viewModel.data[index as! Data.Index], viewModel.activeIndex)
                                        }
                                    Text("삭제하기")
                                        .padding(.top, 6)
                                        .font(.pretendard(size: 12, weight: .bold))
                                        .foregroundStyle(Color.black.opacity(0.58))
                                }
                                Spacer().frame(height: 60)
                            }
                            VStack {
                                Spacer()
                                if #available(iOS 18.0, *) {
                                    Image(systemName: "pencil.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .symbolEffect(.breathe, options: .speed(1.5))
                                        .foregroundStyle(Color.green)
                                        .onTapGesture {
                                            viewModel.dragOffsetYs[index] = 0
                                            bottomFirstClick(viewModel.data[index as! Data.Index], viewModel.activeIndex)
                                        }
                                    Text("편집하기")
                                        .padding(.top, 6)
                                        .font(.pretendard(size: 12, weight: .bold))
                                        .foregroundStyle(Color.black.opacity(0.58))
                                }
                                Spacer().frame(height: 60)
                            }
                        }
                    }
                    content(viewModel.data[index as! Data.Index])
                        .overlay {
                            if viewModel.dragOffsetYs[index] != 0 {
                                Color.white.opacity(0.12)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(width: viewModel.itemWidth)
                        .scaleEffect(x: 1, y: viewModel.itemScaling(viewModel.data[index as! Data.Index]), anchor: .center)
                        .offset(y: viewModel.dragOffsetYs[index])
                }
            }
        }
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
        .offset(x: viewModel.offset)
        .gesture(viewModel.dragGesture)
        .animation(viewModel.offsetAnimation)
        .onReceive(timer: viewModel.timer, perform: viewModel.receiveTimer)
        .onReceiveAppLifeCycle(perform: viewModel.setTimerActive)
    }
}


// MARK: - Initializers

@available(iOS 18.0, OSX 10.15, *)
extension ACarousel {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// - Parameters:
    ///   - data: The data that the ``ACarousel`` instance uses to create views
    ///     dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - index: The index of currently active.
    ///   - spacing: The distance between adjacent subviews, default is 10.
    ///   - headspace: The width of the exposed side subviews, default is 10
    ///   - sidesScaling: The scale of the subviews on both sides, limits 0...1,
    ///     default is 0.8.
    ///   - isWrap: Define views to scroll through in a loop, default is false.
    ///   - autoScroll: A enum that define view to scroll automatically. See
    ///     ``ACarouselAutoScroll``. default is `inactive`.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, index: Binding<Int> = .constant(0), spacing: CGFloat = 10, headspace: CGFloat = 10, sidesScaling: CGFloat = 0.8, isWrap: Bool = false, autoScroll: ACarouselAutoScroll = .inactive, @ViewBuilder content: @escaping (Data.Element) -> Content, bottomFirstClick: @escaping (Data.Element, Int)->(), bottomSecondClick: @escaping (Data.Element, Int)->()) {
        
        self.viewModel = ACarouselViewModel(data, id: id, index: index, spacing: spacing, headspace: headspace, sidesScaling: sidesScaling, isWrap: isWrap, autoScroll: autoScroll)
        self.content = content
        self.bottomFirstClick = bottomFirstClick
        self.bottomSecondClick = bottomSecondClick
    }
    
}

@available(iOS 18.0, OSX 10.15, *)
extension ACarousel where ID == Data.Element.ID, Data.Element : Identifiable {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ACarousel`` instance uses to
    ///     create views dynamically.
    ///   - index: The index of currently active.
    ///   - spacing: The distance between adjacent subviews, default is 10.
    ///   - headspace: The width of the exposed side subviews, default is 10
    ///   - sidesScaling: The scale of the subviews on both sides, limits 0...1,
    ///      default is 0.8.
    ///   - isWrap: Define views to scroll through in a loop, default is false.
    ///   - autoScroll: A enum that define view to scroll automatically. See
    ///     ``ACarouselAutoScroll``. default is `inactive`.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, index: Binding<Int> = .constant(0), spacing: CGFloat = 10, headspace: CGFloat = 10, sidesScaling: CGFloat = 0.8, isWrap: Bool = false, autoScroll: ACarouselAutoScroll = .inactive, @ViewBuilder content: @escaping (Data.Element) -> Content, bottomFirstClick: @escaping (Data.Element, Int)->(), bottomSecondClick: @escaping (Data.Element, Int)->()) {
        
        self.viewModel = ACarouselViewModel(data, index: index, spacing: spacing, headspace: headspace, sidesScaling: sidesScaling, isWrap: isWrap, autoScroll: autoScroll)
        self.content = content
        self.bottomFirstClick = bottomFirstClick
        self.bottomSecondClick = bottomSecondClick
    }
    
}


@available(iOS 18.0, OSX 11.0, *)
struct ACarousel_LibraryContent: LibraryContentProvider {
    let Datas = Array(repeating: _Item(color: .red), count: 3)
    @LibraryContentBuilder
    var views: [LibraryItem] {
        LibraryItem(ACarousel(Datas) { _  in } bottomFirstClick: { _, _ in} bottomSecondClick: { _, _ in }, title: "ACarousel", category: .control)
        LibraryItem(ACarousel(Datas, index: .constant(0), spacing: 10, headspace: 10, sidesScaling: 0.8, isWrap: false, autoScroll: .inactive) { _ in } bottomFirstClick: { _, _ in} bottomSecondClick: { _, _ in }, title: "ACarousel full parameters", category: .control)
    }

    struct _Item: Identifiable {
        let id = UUID()
        let color: Color
    }
}
extension Font {
    static func tenada(size: CGFloat) -> Font {
        return Font.custom("Tenada", size: size)
    }
    static func pretendard(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom("Pretendard-\(fontWeightName(for: weight))", size: size)
    }
    private static func fontWeightName(for weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight: return "Thin"
        case .thin: return "ExtraLight"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .semibold: return "SemiBold"
        case .bold: return "Bold"
        case .heavy: return "ExtraBold"
        case .black: return "Black"
        default: return "Regular"  // 기본값
        }
    }
}