#if os(iOS)
 import SwiftUI

 public struct ImageMenu<Label /* , MenuItems: View */>: View where Label: View {
  public init(
   source: UIImagePickerController.SourceType = .camera,
   options: [UIImagePickerController.SourceType] = [.photoLibrary, .camera],
   onDismiss: (() -> ())? = nil,
   onSet: @escaping (UIImage) -> (),
   // menuItems: (() -> MenuItems)? = nil,
   content: @escaping () -> Label
  ) {
   self.source = source
   self.options = options
   self.onDismiss = onDismiss
   self.onSet = onSet
   // self.menuItems = menuItems
   self.content = content
  }

  @State private var isPresented: Bool = false
  @State private var source: UIImagePickerController.SourceType
  private let onDismiss: (() -> ())?
  @State private var options: [UIImagePickerController.SourceType] =
  [.photoLibrary, .camera]
  private let onSet: (UIImage) -> ()
  // var menuItems: (() -> MenuItems)?
  private let content: () -> Label

  public var body: some View {
   Group {
//    if !isPresented {
   if options.count > 1 {
     Menu(
      content: {
       ForEach(options, id: \.rawValue) { option in
        let isExisting = option == .photoLibrary
        Button(
         action: {
          source = option
          isPresented = true
         },
         label: {
          SwiftUI.Label(
           isExisting ? "Existing Photo ..." : "Camera",
           systemImage:
           isExisting ? "photo.on.rectangle.angled" : "camera.fill"
          )
         }
        )
       }
//      if let menuItems = menuItems {
//      // if showsMenu { Divider() }
//       menuItems()
//      }
      },
      label: content
     )
    } else if let option = options.first {
     Button(
      action: {
       source = option
       isPresented = true
      },
      label: content
     )
    }
   }
   .sheet(
    isPresented: $isPresented,
    onDismiss: {
     isPresented = false
     onDismiss?()
    },
    content: {
     ImagePicker(
      isPresented: $isPresented,
      source: $source,
      onDismiss: onDismiss,
      onSet: onSet
     )
    }
   )
  }
 }

 public struct ImagePicker: UIViewControllerRepresentable {
  init(
   isPresented: Binding<Bool>,
   source: Binding<UIImagePickerController.SourceType>,
   onDismiss: (() -> ())?,
   onSet: @escaping (UIImage) -> ()
  ) {
   _isPresented = isPresented
   _source = source
   self.onDismiss = onDismiss
   self.onSet = onSet
  }

  @Binding private var isPresented: Bool
  @Binding private var source: UIImagePickerController.SourceType
  private let onDismiss: (() -> ())?
  private let onSet: (UIImage) -> ()

  public func makeCoordinator() -> Coordinator {
   Coordinator(self)
  }

  public func makeUIViewController(
   context: Context
  ) -> UIImagePickerController {
   let picker = UIImagePickerController()
   picker.delegate = context.coordinator
   picker.sourceType = source
   return picker
  }

  public func updateUIViewController(
   _: UIImagePickerController,
   context _: UIViewControllerRepresentableContext<ImagePicker>
  ) {}
 }

 public extension ImagePicker {
  final class Coordinator:
   NSObject,
   UINavigationControllerDelegate,
   UIImagePickerControllerDelegate {
   let picker: ImagePicker
   public func imagePickerController(
    _: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
   ) {
    guard let image = info[.originalImage] as? UIImage else { return }
    picker.isPresented = false
    picker.onSet(image)
   }

   public func imagePickerControllerDidCancel(_: UIImagePickerController) {
    picker.isPresented = false
    picker.onDismiss?()
   }

   init(_ picker: ImagePicker) {
    self.picker = picker
   }
  }
 }

// public extension ImageMenu where MenuItems == EmptyView {
// init(
//  onDismiss: (() -> Void)? = nil,
//  options: [UIImagePickerController.SourceType] = [.photoLibrary, .camera],
//  onSet: @escaping (UIImage) -> Void,
//  content: @escaping () -> Label
// ) {
//  self.init(
//   onDismiss: onDismiss,
//   options: options,
//   onSet: onSet,
//  // menuItems: { EmptyView() },
//   content: content
//  )
// }
// }
 public extension View {
  func photoPicker(
   isPresented: Binding<Bool>,
   onDismiss perform: (() -> ())? = .none,
   source: Binding<UIImagePickerController.SourceType> = .constant(.camera),
   options _: [UIImagePickerController.SourceType] = .empty,
   onSet: @escaping (UIImage) -> () // ,
   // menuItems: (() -> MenuItems)? = nil
  ) -> some View {
   sheet(
    isPresented: isPresented,
    content: {
     ImagePicker(
      isPresented: isPresented,
      source: source,
      onDismiss: perform,
      onSet: onSet // ,
      // menuItems: menuItems
     )
    }
   )
  }
 }
#endif
