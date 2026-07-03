import React, { useState } from 'react';
import { motion, useMotionValue, useTransform, PanInfo, animate } from 'framer-motion';

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
  const [isOpen, setIsOpen] = useState<'left' | 'right' | null>(null);

  // Maps coordinates to colors or opacity for smooth transitions
  const leftOpacity = useTransform(x, [0, 80], [0, 1]);
  const rightOpacity = useTransform(x, [-80, 0], [1, 0]);

  const handleDragEnd = (event: any, info: PanInfo) => {
    const triggerThreshold = 150; // Drag far enough to trigger direct action
    const snapThreshold = 40;     // Drag past this to keep menu open

    if (info.offset.x > triggerThreshold) {
      if (onSwipeRightComplete) {
        onSwipeRightComplete();
      }
      animate(x, 0, { type: 'spring', damping: 25, stiffness: 200 });
      setIsOpen(null);
    } else if (info.offset.x < -triggerThreshold) {
      if (onSwipeLeftComplete) {
        onSwipeLeftComplete();
      }
      animate(x, 0, { type: 'spring', damping: 25, stiffness: 200 });
      setIsOpen(null);
    } else if (info.offset.x > snapThreshold) {
      // Snap open to show left actions (shifted right)
      animate(x, 140, { type: 'spring', damping: 20, stiffness: 180 });
      setIsOpen('left');
    } else if (info.offset.x < -snapThreshold) {
      // Snap open to show right actions (shifted left)
      animate(x, -160, { type: 'spring', damping: 20, stiffness: 180 });
      setIsOpen('right');
    } else {
      // Snap closed
      animate(x, 0, { type: 'spring', damping: 25, stiffness: 220 });
      setIsOpen(null);
    }
  };

  const handleCardClick = (e: React.MouseEvent) => {
    // If menu is open, intercept click to close the menu first
    if (isOpen) {
      e.stopPropagation();
      e.preventDefault();
      animate(x, 0, { type: 'spring', damping: 25, stiffness: 220 });
      setIsOpen(null);
    }
  };

  return (
    <div className="relative overflow-hidden w-full rounded-xl select-none my-2 shadow-sm">
      {/* Background Actions Layer (hidden under the main card) */}
      <div className="absolute inset-0 flex items-center justify-between w-full h-full rounded-xl z-0">
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
          className="absolute inset-y-0 right-0 flex items-center bg-zinc-600 dark:bg-zinc-800 text-white rounded-r-xl px-4 w-1/2 justify-end gap-2"
        >
          {rightActions}
        </motion.div>
      </div>

      {/* Foreground Draggable Card */}
      <motion.div
        drag="x"
        dragConstraints={{ left: rightActions ? -200 : 0, right: leftActions ? 200 : 0 }}
        dragElastic={0.4}
        style={{ x }}
        onDragEnd={handleDragEnd}
        onClickCapture={handleCardClick}
        className="relative z-10 w-full bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl cursor-grab active:cursor-grabbing"
      >
        {children}
      </motion.div>
    </div>
  );
};
