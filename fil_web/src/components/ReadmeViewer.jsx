import React, { useState, useEffect } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import './ReadmeViewer.css';

const ReadmeViewer = ({ filePath }) => {
    const [content, setContent] = useState('');

    useEffect(() => {
        fetch(filePath)
            .then(res => res.text())
            .then(text => setContent(text))
            .catch(err => console.error(err));
    }, [filePath]);

    return (
        <div className="readme-viewer">
            <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
        </div>
    );
};

export default ReadmeViewer;
