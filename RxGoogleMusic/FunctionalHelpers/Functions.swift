//
//  Functions.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 31/10/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

public func |> <A, B>(a: A, f: @escaping (A) -> B) -> B {
    return f(a)
}

public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { input in
        return g(f(input))
    }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in
        return { b in
            return f(a, b)
        }
    }
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in
        return { b in
            return { c in
                return f(a, b, c)
            }
        }
    }
}

public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in
        return { a in
            return f(a)(b)
        }
    }
}

public func flip<A, B, C, D>(_ f: @escaping (A) -> (B) -> (C) -> D) -> (C) -> (B) -> (A) -> D {
    return { c in
        return { b in
            return { a in
                return f(a)(b)(c)
            }
        }
    }
}
