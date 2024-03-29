context("dnf")

describe("as_dnf", {
  it("works with simple expressions", {
    dnf <- as_dnf(quote(x > 1))
    expect_equal(dnf[[1]], quote(x > 1))
    expect_equal(length(dnf), 1)

    dnf <- as_dnf(quote(x == 1))
    expect_equal(dnf[[1]], quote(x == 1))
    expect_equal(length(dnf), 1)

    dnf <- as_dnf(quote(A == "a"))
    expect_equal(dnf[[1]], quote(A == "a"))
    expect_equal(length(dnf), 1)
  })

  it("works with if statements", {
    dnf <- as_dnf(quote(if (x > 1) y < 0))
    expect_equivalent(dnf, expression(x <=1, y < 0))


    dnf <- as_dnf(quote(if (A == "a") y < 0))
    expect_equivalent(dnf, expression(A != "a", y < 0))

    dnf <- as_dnf(quote(if (A != "a") y < 0))
    expect_equivalent(dnf, expression(A == "a", y < 0))

    dnf <- as_dnf(quote(if (A %in% "a") y < 0))
    expect_equivalent(dnf, expression(!(A %in% "a"), y < 0))
  })

  it("works with complex if statements", {
    dnf <- as_dnf(quote(if (x > 1 & z > 1) y < 0))
    expect_equal(dnf[[1]], quote(x <= 1))
    expect_equal(dnf[[2]], quote(z <= 1))
    expect_equal(dnf[[3]], quote(y < 0))

    expect_equal(length(dnf), 3)

    dnf <- as_dnf(quote(if (x > 1 & z > 1 & w > 1) y < 0))
    expect_equivalent(dnf, expression(x <=1, z <= 1, w <= 1, y < 0))
  })

  it("works with logical if statement",{
    dnf <- as_dnf(quote(if (A == TRUE) x > 0))
    expect_equivalent(as.expression(dnf), expression(A == FALSE | x > 0))

    dnf <- as_dnf(quote(if (A == FALSE) x > 0))
    expect_equivalent(as.expression(dnf), expression(A == TRUE | x > 0))

    dnf <- as_dnf(quote(if (A == FALSE & B == TRUE) x > 0))
    expect_equivalent(as.expression(dnf), expression(A == TRUE | B == FALSE | x > 0))

    dnf <- as_dnf(quote(if (A != FALSE) x > 0))
    expect_equivalent(as.expression(dnf), expression(A == FALSE | x > 0))

    dnf <- as_dnf(quote(if (A != TRUE) x > 0))
    expect_equivalent(as.expression(dnf), expression(A == TRUE | x > 0))
  })

  it("works on issue of negated linear consequent", {
    dnf <- as_dnf(quote(if (A==TRUE) !x < 0))
    expect_equivalent(as.expression(dnf), expression(A == FALSE | x >= 0))

    dnf <- as_dnf(quote(if (y > 0) !x < 0))
    expect_equivalent(as.expression(dnf), expression(y <= 0 | x >= 0))

    dnf <- as_dnf(quote(if (!y > 0) !x < 0))
    expect_equivalent(as.expression(dnf), expression(y > 0 | x >= 0))

    dnf <- as_dnf(quote(if (!y > 0) !x < 0 | z > 0))
    expect_equivalent(as.expression(dnf), expression(y > 0 | x >= 0 | z > 0))

    dnf <- as_dnf(quote(if (!y > 0) !x < 0 | !z > 0))
    expect_equivalent(as.expression(dnf), expression(y > 0 | x >= 0 | z <= 0))
  })

  it("works with & clause", {
    dnf <- as_dnf(quote(a & b))
    expect_equivalent(as.expression(dnf)[[1]], quote((a & b)))

    dnf <- as_dnf(quote(c | (a & b)))
    expect_equivalent(as.expression(dnf)[[1]], quote(c |(a&b)))
  })

  it("works with || clause in if", {
    e <- quote(if(a || b) c)
    dnf <- as_dnf(e)
  })

  it("generates multiple dnfs with & clause", {
    dnf <- as_dnf(quote(a & b))
    expect_equivalent(as_dnfs(dnf), list(as_dnf(quote(a)), as_dnf(quote(b))))

    dnf <- as_dnf(quote(c | (a & b)))
    expect_equivalent( as_dnfs(dnf)
                     , list( as_dnf(quote(c | a))
                           , as_dnf(quote(c | b))
                           )
                     )
  })

  it("handles in_range", {
    e <- quote(in_range(age, 18, 67))
    dnf <- as_dnf(e)
  })

})
