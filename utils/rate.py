#!/usr/bin/env python3

import argparse

def rate(lo, hi, ratio):
    return lo + (hi - lo) * ratio


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("lo", type=float)
    parser.add_argument("hi", type=float)
    parser.add_argument("--ratio", type=float)
    parser.add_argument("--reverse", action="store_true")
    args = parser.parse_args()

    # ratio 0.382 0.314 0.2718
    ratio = args.ratio if args.ratio is not None else 0.618
    if args.reverse:
        assert(ratio <= 1)
        ratio = 1-ratio

    print(round(rate(args.lo, args.hi, ratio), 2))
