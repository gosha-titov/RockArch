/// A dependency that is injected in a module during loading.
///
/// When one module loads another, it can pass a dependency that should be injected.
/// It's usually a single service or multiple ones.
public typealias RADependency = Any
