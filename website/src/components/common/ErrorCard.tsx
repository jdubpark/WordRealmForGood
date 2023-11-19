import React from "react";

interface ErrorCardProps {
  retry?: () => void;
  retryText?: string;
  text: string;
  subtext?: string;
}

export function ErrorCard({ retry, retryText, text, subtext }: ErrorCardProps) {
  const buttonText = retryText ?? "Try Again";
  return (
    <div className="card">
      <div className="card-body text-center">
        {text}
        {retry && (
          <>
            <span
              className="btn btn-white d-none d-md-inline ms-3"
              onClick={retry}
            >
              {buttonText}
            </span>
            <div className="d-block d-md-none mt-4">
              <span className="btn btn-white w-100" onClick={retry}>
                {buttonText}
              </span>
            </div>
            {subtext && (
              <div className="text-muted">
                <hr></hr>
                {subtext}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
