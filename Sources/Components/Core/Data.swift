/// A dependency that is injected in a module during loading.
///
/// When one module loads another, it can pass a dependency that should be injected.
/// It's usually a single service or multiple ones.
public typealias RADependency = Any



/// A context within which a module starts the work.
///
/// When one module shows another, it can pass a context in order to indicate key information.
///
/// For example, you have a table with friends, when a user clicks on a row, you show a friend profile.
/// So, you have the `FriendsModule` and `FriendProfileModule` classes.
/// That is, the context for the second module is a `friendID` that you pass from the first module.
public typealias RAContext = Any
