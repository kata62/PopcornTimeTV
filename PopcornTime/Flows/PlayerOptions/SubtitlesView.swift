//
//  SubtitlesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct SubtitlesView: View {
    let theme = Theme()
    @Binding var currentDelay: Int
    @Binding var currentEncoding: String
    @Binding var currentSubtitle: Subtitle?
    @StateObject var viewModel: SubtitlesViewModel
    @State var showExtendedSubtitles = false
    @State var triggerRefresh = false
    
    var body: some View {
        HStack (alignment:.top, spacing: 0) {
            if !showExtendedSubtitles {
                Spacer()
                languageSection
                    .frame(width: theme.languageSectionWidth)
                delaySection
                #if os(iOS)
                    .frame(width: theme.delaySectionWidth)
                #endif
                encodingSection
                
                Spacer()
            } else {
                ExtendedSubtitlesView(currentSubtitle: subtitleBinding,
                                      subtitles: viewModel.subtitles,
                                      isPresented: $showExtendedSubtitles)
                .padding(.horizontal, theme.extendedSpacing)
            }
        }
        #if os(tvOS)
        .focusSection()
        #endif
    }
    
    var subtitleBinding: Binding<Subtitle?> {
        return Binding.init(get: {
            currentSubtitle
        }, set: { item in
            currentSubtitle = item
            viewModel.didSelectSubtitle(item)
            triggerRefresh.toggle()
        })
    }
    
    var languageSection: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(text: "Language")
                if viewModel.subtitles.isEmpty {
                    Text("No subtitles available.")
                        .foregroundColor(.appGray)
                        .font(.system(size: theme.noLanguageFontSize, weight: .medium))
                        .padding(.leading, 20)
                } else {
                    ScrollViewReader { scroll in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 15) {
                                ForEach(viewModel.subtitlesInView) { subtitle in
                                    button(text: subtitle.language, isSelected: subtitle.language == currentSubtitle?.language, onFocus: {
                                        scroll.scrollTo(subtitle.language, anchor: .center)
                                    }) {
                                        if subtitle.language == viewModel.selectOther {
                                            self.showExtendedSubtitles = true
                                        } else {
                                            currentSubtitle = currentSubtitle == subtitle ? nil : subtitle
                                            triggerRefresh.toggle()
                                        }
                                    }
                                    .id(subtitle.language)
                                }
                            }
                        }
                        .onAppear(perform: {
                            viewModel.subtitlesInView = viewModel.generateSubtitles(currentSubtitle: currentSubtitle)
                            scroll.scrollTo(currentSubtitle?.language, anchor: .center)
                        })
                    }
                }
            }
        }
        #if os(tvOS)
        .focusSection()
        #endif
    }
    
    @ViewBuilder
    var delaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Delay")
            ScrollViewReader { scroll in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.delays, id: \.self) { delay in
                            button(text: viewModel.delayText(delay: delay), isSelected: delay == currentDelay, onFocus: {
                                withAnimation {
                                    scroll.scrollTo(delay, anchor: .center)
                                }
                            }) {
                                currentDelay = delay
                                triggerRefresh.toggle()
                            }
                            .id(delay)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        scroll.scrollTo(currentDelay, anchor: .center)
                    }
                }
            }
        }
        #if os(tvOS)
        .focusSection()
        #endif
    }
    
    @ViewBuilder
    var encodingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Encoding")
            ScrollViewReader { scroll in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.encodingsKeys, id: \.self) { key in
                            let item = viewModel.encodings[key]
                            
                            button(text: key, isSelected: currentEncoding == item, onFocus: {
                                withAnimation {
                                    scroll.scrollTo(item, anchor: .center)
                                }
                            }) {
                                currentEncoding = item!
                                triggerRefresh.toggle()
                            }
                            .id(item)
                        }
                    }
                }
                .onAppear(perform: {
                    scroll.scrollTo(currentEncoding, anchor: .center)
                })
            }
            #if os(tvOS)
            .focusSection()
            #endif
        }
    }
    
    func sectionHeader(text: String) -> some View {
        Text(text.localized.uppercased())
            .font(.system(size: theme.sectionFontSize, weight: .bold))
            .foregroundColor(.appGray)
            .padding(.leading, theme.sectionLeading)
    }
    
    func button(text: String, isSelected: Bool, onFocus: @escaping () -> Void, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: theme.textButtonSpacing) {
                if (isSelected) {
                    Image(systemName: "checkmark")
                } else {
                    Text("").frame(width: theme.contentFontSize)
                }
                Text(text)
                    .font(.system(size: theme.contentFontSize, weight: .medium))
            }
        })
            .padding([.leading, .trailing], theme.sectionLeading * 0.5)
            .buttonStyle(PlainButtonStyle(onFocus: onFocus))
    }
}


extension SubtitlesView {
    struct Theme {
        let sectionLeading: CGFloat = value(tvOS: 100, macOS: 50, compactSize: 5)
        let sectionFontSize: CGFloat = value(tvOS: 32, macOS: 20, compactSize: 17)
        let contentFontSize: CGFloat = value(tvOS: 31, macOS: 19, compactSize: 16)
        let noLanguageFontSize: CGFloat = value(tvOS: 35, macOS: 23)
        let languageSectionWidth: CGFloat = value(tvOS: 390, macOS: 250, compactSize: 150)
        let delaySectionWidth: CGFloat = value(tvOS: 0, macOS: 150, compactSize: 100)
        let textButtonSpacing: CGFloat = value(tvOS: 20, macOS: 20, compactSize: 5)
        let extendedSpacing: CGFloat = value(tvOS: 10, macOS: 10, compactSize: 0)
    }
}

struct SubtitlesView_Previews: PreviewProvider {
    static var previews: some View {
        let subtitle = Subtitle(name: "Test", language: "English", fileId: 0, fileName: "", ISO639: "")
        let encoding = SubtitleSettings.encodings.values.first!
        let enKey: String = Locale.current.localizedString(forLanguageCode: "en") ?? ""
        let subtitles: Dictionary<String, [Subtitle]> = [enKey : [subtitle]]

        Group {
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(encoding),
                          currentSubtitle: .constant(nil),
                          viewModel:SubtitlesViewModel()
            )
            
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(encoding),
                          currentSubtitle: .constant(subtitle),
                        viewModel: SubtitlesViewModel(subtitles: subtitles)
            )
            
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(encoding),
                          currentSubtitle: .constant(subtitle),
                          viewModel:SubtitlesViewModel(subtitles: subtitles),
                showExtendedSubtitles: true
            )
        }
        .frame(maxHeight: 300)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
