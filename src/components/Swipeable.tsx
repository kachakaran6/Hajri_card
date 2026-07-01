import React from 'react';
import { motion, useMotionValue, useTransform, PanInfo } from 'framer-motion';

interface SwipeableProps {
  children: React.ReactNode;
  leftActions?: React.ReactNode; // Content shown when swiped right (revealing left side)
  rightActions?: React.ReactNode; // Content shown when swiped left (revealing right side)
  onSwipeLeftComplete?: () => void; // Triggered on full swipe left
  onSwipeRightComplete?: () => void; // Triggered on full swipe right
}

export const Swipeable: React.FC<SwipeableProps> = ({
  children,
  leftActions,
  rightActions,
  onSwipeLeftComplete,
  onSwipeRightComplete
}) => {
  const x = useMotionValue(0);

  // Maps coordinates to colors or opacity for smooth transitions
  const leftOpacity = useTransform(x, [0, 80], [0, 1]);
  const rightOpacity = useTransform(x, [-80, 0], [1, 0]);

  const handleDragEnd = (event: any, info: PanInfo) => {
    const swipeThreshold = 140; // Pixels needed for a full swipe action

    if (info.offset.x > swipeThreshold) {
      if (onSwipeRightComplete) {
        onSwipeRightComplete();
      }
    } else if (info.offset.x < -swipeThreshold) {
      if (onSwipeLeftComplete) {
        onSwipeLeftComplete();
      }
    }
  };

  return (
    <div className="relative overflow-hidden w-full rounded-xl select-none my-2 shadow-sm">
      {/* Background Actions Layer (hidden under the main card) */}
      <div className="absolute inset-0 flex items-center justify-between w-full h-full rounded-xl">
        {/* Left Actions (reveals on dragging right) */}
        <motion.div
          style={{ opacity: leftOpacity }}
          className="absolute inset-y-0 left-0 flex items-center bg-green-500 text-white rounded-l-xl px-4 w-1/2 justify-start gap-2"
        >
          {leftActions}
        </motion.div>

        {/* Right Actions (reveals on dragging left) */}
        <motion.div
          style={{ opacity: rightOpacity }}
          className="absolute inset-y-0 right-0 flex items-center bg-zinc-500 dark:bg-zinc-800 text-white rounded-r-xl px-4 w-1/2 justify-end gap-2"
        >
          {rightActions}
        </motion.div>
      </div>

      {/* Foreground Draggable Card */}
      <motion.div
        drag="x"
        dragConstraints={{ left: -180, right: 180 }}
        dragElastic={0.4}
        style={{ x }}
        onDragEnd={handleDragEnd}
        className="relative z-10 w-full bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 rounded-xl cursor-grab active:cursor-grabbing transition-colors duration-150"
      >
        {children}
      </motion.div>
    </div>
  );
};
