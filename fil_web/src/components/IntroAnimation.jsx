import React from 'react';
import { motion } from 'framer-motion';

const IntroAnimation = ({ onComplete }) => {
    return (
        <motion.div
            className="intro-overlay"
            initial={{ opacity: 1 }}
            animate={{ opacity: 0 }}
            transition={{ duration: 1, delay: 2.5, ease: "easeInOut" }}
            onAnimationComplete={onComplete}
            style={{
                position: 'fixed',
                top: 0,
                left: 0,
                width: '100%',
                height: '100%',
                background: '#000',
                zIndex: 9999,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                pointerEvents: 'none'
            }}
        >
            <motion.svg
                width="100%"
                height="100%"
                viewBox="0 0 100 100"
                preserveAspectRatio="none"
                style={{ position: 'absolute' }}
            >
                <motion.path
                    d="M0,50 Q25,0 50,50 T100,50"
                    fill="none"
                    stroke="white"
                    strokeWidth="0.5"
                    initial={{ pathLength: 0, opacity: 0 }}
                    animate={{ pathLength: 1, opacity: 1 }}
                    transition={{ duration: 2, ease: "easeInOut" }}
                />
                {/* Mirror thread */}
                <motion.path
                    d="M0,50 Q25,100 50,50 T100,50"
                    fill="none"
                    stroke="white"
                    strokeWidth="0.5"
                    initial={{ pathLength: 0, opacity: 0 }}
                    animate={{ pathLength: 1, opacity: 1 }}
                    transition={{ duration: 2, delay: 0.2, ease: "easeInOut" }}
                />
            </motion.svg>

            <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 1, duration: 0.8 }}
            >
                <img src="./assets/logo/logo.svg" alt="FIL" style={{ width: '200px' }} />
            </motion.div>
        </motion.div>
    );
};

export default IntroAnimation;
