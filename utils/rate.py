#!/usr/bin/env python3

import argparse

def rate(lo, hi, ratio):
    return lo + (hi - lo) * ratio

def earn(lo, sell):
    return (sell - lo) / lo * 100

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("lo", type=float)
    parser.add_argument("hi", type=float)
    parser.add_argument("--ratio", type=float)
    parser.add_argument("--amount", type=int)
    parser.add_argument("--reverse", action="store_true")

    parser.add_argument('--type', type=str)
    args = parser.parse_args()

    def getRatio():
        return args.ratio if args.ratio is not None else 0.618

    if args.type is None:
        # ratio 0.382 0.314 0.2718
        ratio = getRatio()
        if args.reverse:
            assert(ratio <= 1)
            ratio = 1-ratio
        sell = round(rate(args.lo, args.hi, ratio), 2)
        print("Range value: {}", sell)
        print("Earn: ", earn(args.lo, sell), "%")
    elif args.type == 'down':
        ratio = args.ratio if args.ratio is not None else 0.0618
        sell = round(args.hi - (args.hi * ratio), 2)
        print("Down value: {}", sell)
        print("Earn: ", earn(args.lo, sell), "%")
