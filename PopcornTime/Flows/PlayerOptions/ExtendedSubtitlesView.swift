//
//  ExtendedSubtitlesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 27.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct ExtendedSubtitlesView: View {
    let theme = Theme()
    @Binding var currentSubtitle: Subtitle?
    @State var triggerRefresh = false
    @State var showLanguageAlert = false
    var subtitles = Dictionary<String, [Subtitle]>()
    
    @Binding var isPresented: Bool
    let enLocale = Locale.current.localizedString(forLanguageCode: "en")!
    var displaySubtitles: [Subtitle]  {
        return subtitles[currentSubtitle?.language ?? enLocale] ?? []
    }
    
    var body: some View {
        HStack (alignment:.top, spacing: theme.sectionSpacing) {
            Spacer()
            subtitlesSection
            languageSection
            Spacer()
        }
        .frame(maxHeight: theme.maxHeight)
    }
    
    var subtitlesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    self.isPresented = false
                } label: {
                    sectionHeader(text: "❮ Available Subtitles")
                }
                .buttonStyle(PlainButtonStyle(onFocus: {}))
                Spacer()
            }
            
            ScrollViewReader { scroll in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(displaySubtitles) { subtitle in
                            button(subtitle: subtitle, isSelected: subtitle.name == currentSubtitle?.name) {
                                self.currentSubtitle = currentSubtitle == subtitle ? nil : subtitle
                                self.triggerRefresh.toggle()
                            }
                            .id(subtitle.language)
                        }
                    }
                }
                .onAppear(perform: {
                    scroll.scrollTo(currentSubtitle?.language, anchor: .center)
                })
            }
        }
        #if os(tvOS)
        .focusSection()
        #endif
    }
    
    var languageSection: some View {
        VStack(alignment:.leading, spacing: 0) {
            sectionHeader(text: "Language".uppercased())
                .foregroundColor(.appGray)
            
            Button(action: {
                self.showLanguageAlert = true
            }, label: {
                Text(currentSubtitle?.language ?? "None".localized) + Text(" ❯")
                    .font(.system(size: theme.contentFontSize, weight: .regular))
            })
                .buttonStyle(PlainButtonStyle(onFocus: {}))
                .padding(.leading)
            Spacer()
        }
        .confirmationDialog(Text("Select Language".localized), isPresented: $showLanguageAlert, titleVisibility: .visible, actions: {
            languageButtons
            Button("Cancel", role: .cancel, action: {})
        })
        #if os(tvOS)
        .focusSection()
        #endif
    }
    
    @ViewBuilder
    var languageButtons: some View {
        let items = Array(subtitles.keys).sorted()
        ForEach(items, id: \.self) { language in
            Button {
                self.currentSubtitle = self.subtitles[language]?.first
            } label: { Text(language) }
        }
    }
    
    func sectionHeader(text: String) -> some View {
        Text(text.localized)
            .font(.system(size: theme.sectionFontSize, weight: .regular))
            .padding()
    }
    
    func button(subtitle: Subtitle, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: theme.textButtonSpacing) {
                if (isSelected) {
                    Image(systemName: "checkmark")
                } else {
                    Text("").frame(width: theme.contentFontSize)
                }
                Text(subtitle.name)
                    .font(.system(size: theme.contentFontSize, weight: .regular))
                Spacer()
                
            }
            .padding([.leading, .trailing], theme.sectionLeading) // allow space for scale animation
        })
        .buttonStyle(PlainButtonStyle(onFocus: {}))
    }
}

extension ExtendedSubtitlesView {
    struct Theme {
        let sectionFontSize: CGFloat = value(tvOS: 38, macOS: 25, compactSize: 17)
        let sectionLeading: CGFloat = value(tvOS: 50, macOS: 25, compactSize: 5)
        let sectionSpacing: CGFloat = value(tvOS: 25, macOS: 25, compactSize: 0)
        let contentFontSize: CGFloat = value(tvOS: 32, macOS: 20, compactSize: 16)
        let maxHeight: CGFloat = value(tvOS: 860, macOS: 400)
        let textButtonSpacing: CGFloat = value(tvOS: 20, macOS: 20, compactSize: 5)
    }
}


struct ExtendedSubtitlesView_Previews: PreviewProvider {
    static var previews: some View {
        let subtitle = Subtitle(name: "Test long testing running on this device", language: "English", fileId: 0, fileName: "", ISO639: "")
        Group {
            ExtendedSubtitlesView(
                currentSubtitle: .constant(subtitle),
                subtitles: [Locale.current.localizedString(forLanguageCode: "en")! : [subtitle], Locale.current.localizedString(forLanguageCode: "ro")! : [subtitle]],
                isPresented: .constant(true)
            )
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
